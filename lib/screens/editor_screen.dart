import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../editor/puzzle_editor_controller.dart';
import '../models/puzzle.dart';
import '../theme/app_theme.dart';
import '../utils/json_download.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final PuzzleEditorController _editor = PuzzleEditorController();
  final _rowsController = TextEditingController(text: '11');
  final _colsController = TextEditingController(text: '11');
  final _idController = TextEditingController(text: 'bolum_1');
  final _titleController = TextEditingController(text: 'Bölüm 1');
  final _categoryController = TextEditingController(text: 'Genel');
  final _rightClueController = TextEditingController();
  final _downClueController = TextEditingController();
  final _rightAnswerController = TextEditingController();
  final _downAnswerController = TextEditingController();
  GridPosition? _syncedSelection;

  @override
  void initState() {
    super.initState();
    _editor.addListener(_onEditorChanged);
  }

  void _onEditorChanged() {
    if (_editor.selectedCell != _syncedSelection) {
      _syncedSelection = _editor.selectedCell;
      _syncQuestionFields();
    }
    if (mounted) setState(() {});
  }

  void _syncQuestionFields() {
    final position = _editor.selectedCell;
    if (position == null) {
      _rightClueController.clear();
      _downClueController.clear();
      _rightAnswerController.clear();
      _downAnswerController.clear();
      return;
    }

    final cell = _editor.cellAt(position);
    _rightClueController.text = cell.questionRight;
    _downClueController.text = cell.questionDown;
    _rightAnswerController.text = _answerFor(position, WordDirection.right);
    _downAnswerController.text = _answerFor(position, WordDirection.down);
  }

  String _answerFor(GridPosition clue, WordDirection direction) {
    for (final word in _editor.words) {
      if (word.clueCell == clue && word.direction == direction) {
        return word.answer;
      }
    }
    return '';
  }

  void _applyGridSize() {
    final rows = int.tryParse(_rowsController.text);
    final cols = int.tryParse(_colsController.text);
    if (rows == null || cols == null || rows < 1 || cols < 1) {
      _showMessage('Satır ve sütun için geçerli bir sayı girin.');
      return;
    }
    _editor.resize(rows, cols);
  }

  void _updateQuestion() {
    _editor.updateQuestion(
      rightClue: _rightClueController.text,
      downClue: _downClueController.text,
      rightAnswer: _rightAnswerController.text,
      downAnswer: _downAnswerController.text,
    );
  }

  void _downloadJson() {
    _editor.updateMetadata(
      id: _idController.text,
      puzzleTitle: _titleController.text,
      puzzleCategory: _categoryController.text,
    );
    final filename = '${_editor.puzzleId}.json';
    downloadJsonFile(filename, _editor.toPrettyJson());
    _showMessage('$filename indirildi.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _editor
      ..removeListener(_onEditorChanged)
      ..dispose();
    for (final controller in [
      _rowsController,
      _colsController,
      _idController,
      _titleController,
      _categoryController,
      _rightClueController,
      _downClueController,
      _rightAnswerController,
      _downAnswerController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulmaca Editörü'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _downloadJson,
              icon: const Icon(Icons.download_rounded),
              label: const Text('JSON İndir'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkTurquoise,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 980;
          final grid = _GridEditor(editor: _editor);
          final panel = _EditorPanel(
            editor: _editor,
            rowsController: _rowsController,
            colsController: _colsController,
            idController: _idController,
            titleController: _titleController,
            categoryController: _categoryController,
            rightClueController: _rightClueController,
            downClueController: _downClueController,
            rightAnswerController: _rightAnswerController,
            downAnswerController: _downAnswerController,
            onResize: _applyGridSize,
            onQuestionChanged: _updateQuestion,
          );

          if (desktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: grid),
                SizedBox(width: 380, child: panel),
              ],
            );
          }
          return ListView(
            children: [
              SizedBox(height: constraints.maxHeight * 0.58, child: grid),
              panel,
            ],
          );
        },
      ),
    );
  }
}

class _GridEditor extends StatelessWidget {
  const _GridEditor({required this.editor});

  final PuzzleEditorController editor;

  @override
  Widget build(BuildContext context) {
    const cellSize = 38.0;
    return Container(
      color: const Color(0xFFF0F7F6),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: editor.cols * cellSize,
              height: editor.rows * cellSize,
              child: Stack(
                children: [
                  for (var row = 0; row < editor.rows; row++)
                    for (var col = 0; col < editor.cols; col++)
                      Positioned(
                        left: col * cellSize,
                        top: row * cellSize,
                        width: cellSize,
                        height: cellSize,
                        child: _EditorCellView(
                          editor: editor,
                          position: GridPosition(row, col),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorCellView extends StatelessWidget {
  const _EditorCellView({required this.editor, required this.position});

  final PuzzleEditorController editor;
  final GridPosition position;

  @override
  Widget build(BuildContext context) {
    final cell = editor.cellAt(position);
    final selected = editor.selectedCell == position;
    final color = switch (cell.type) {
      CellType.answer => Colors.white,
      CellType.question => AppColors.turquoise,
      CellType.black => AppColors.blackCell,
    };

    return Tooltip(
      message: '${position.row}, ${position.col} · ${cell.type.name}',
      child: InkWell(
        onTap: () => editor.cycleCell(position),
        onLongPress: cell.type == CellType.question
            ? () => editor.selectQuestion(position)
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: selected ? Colors.orange : AppColors.ink,
              width: selected ? 3 : 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: cell.type == CellType.question
              ? const Icon(Icons.help_outline, color: Colors.white, size: 17)
              : cell.partOf.isNotEmpty
              ? Text(
                  '${cell.partOf.length}',
                  style: const TextStyle(
                    color: AppColors.darkTurquoise,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.editor,
    required this.rowsController,
    required this.colsController,
    required this.idController,
    required this.titleController,
    required this.categoryController,
    required this.rightClueController,
    required this.downClueController,
    required this.rightAnswerController,
    required this.downAnswerController,
    required this.onResize,
    required this.onQuestionChanged,
  });

  final PuzzleEditorController editor;
  final TextEditingController rowsController;
  final TextEditingController colsController;
  final TextEditingController idController;
  final TextEditingController titleController;
  final TextEditingController categoryController;
  final TextEditingController rightClueController;
  final TextEditingController downClueController;
  final TextEditingController rightAnswerController;
  final TextEditingController downAnswerController;
  final VoidCallback onResize;
  final VoidCallback onQuestionChanged;

  @override
  Widget build(BuildContext context) {
    final questionSelected = editor.selectedCell != null;
    return Material(
      color: Colors.white,
      elevation: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Bulmaca Ayarları',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: idController,
            decoration: const InputDecoration(
              labelText: 'Dosya / bulmaca ID',
              hintText: 'bolum_1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Başlık',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NumberField(controller: rowsController, label: 'Satır'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberField(controller: colsController, label: 'Sütun'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onResize,
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Gridi Oluştur'),
          ),
          const Divider(height: 32),
          const Text(
            'Hücre tipi için tıklayın:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Legend(color: Colors.white, label: 'Cevap'),
              _Legend(color: AppColors.turquoise, label: 'Soru'),
              _Legend(color: AppColors.blackCell, label: 'Siyah'),
            ],
          ),
          const Divider(height: 32),
          Text(
            questionSelected
                ? 'Soru Hücresi (${editor.selectedCell!.row}, ${editor.selectedCell!.col})'
                : 'Soru hücresi seçilmedi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (!questionSelected)
            const Text(
              'Beyaz bir hücreye tıklayıp turkuaz yaptığınızda soru alanları açılır.',
            )
          else ...[
            _QuestionField(
              controller: rightClueController,
              label: 'Sağa soru metni',
              onChanged: onQuestionChanged,
            ),
            _QuestionField(
              controller: rightAnswerController,
              label: 'Sağa cevap kelimesi',
              onChanged: onQuestionChanged,
              capitalization: TextCapitalization.characters,
            ),
            _QuestionField(
              controller: downClueController,
              label: 'Aşağı soru metni',
              onChanged: onQuestionChanged,
            ),
            _QuestionField(
              controller: downAnswerController,
              label: 'Aşağı cevap kelimesi',
              onChanged: onQuestionChanged,
              capitalization: TextCapitalization.characters,
            ),
            if (editor.validationMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  editor.validationMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.capitalization = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        textCapitalization: capitalization,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: AppColors.ink),
          ),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
