import 'package:flutter/material.dart';

void main() => runApp(const BuilderApp());

class BuilderApp extends StatelessWidget {
  const BuilderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const UIBuilderScreen(),
    );
  }
}

class UIBuilderScreen extends StatefulWidget {
  const UIBuilderScreen({Key? key}) : super(key: key);

  @override
  State<UIBuilderScreen> createState() => _UIBuilderScreenState();
}

class _UIBuilderScreenState extends State<UIBuilderScreen> {
  final List<WidgetData> widgets = [];
  WidgetData? selectedWidget;
  bool showGrid = true;
  final double gridSize = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Builder'),
        actions: [
          IconButton(
            icon: Icon(showGrid ? Icons.grid_on : Icons.grid_off),
            onPressed: () => setState(() => showGrid = !showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: _showGeneratedCode,
          ),
        ],
      ),
      body: Row(
        children: [
          // Components Panel
          SizedBox(
            width: 200,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _buildDraggableComponent('Button'),
                  _buildDraggableComponent('Text'),
                  _buildDraggableComponent('TextField'),
                  _buildDraggableComponent('Container'),
                  _buildDraggableComponent('AppBar'),
                  _buildDraggableComponent('FloatingActionButton'),
                  _buildDraggableComponent('Image'),
                  _buildDraggableComponent('Card'),
                  _buildDraggableComponent('Icon'),
                ],
              ),
            ),
          ),
          // Canvas
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8),
              child: DragTarget<String>(
                onAcceptWithDetails: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.offset);
                  _addWidget(details.data, localPosition);
                },
                builder: (context, _, __) => Stack(
                  children: [
                    if (showGrid) _buildGrid(),
                    ...widgets.map((w) => _buildWidget(w)),
                  ],
                ),
              ),
            ),
          ),
          // Properties Panel
          if (selectedWidget != null) _buildPropertiesPanel(),
        ],
      ),
    );
  }

  Widget _buildDraggableComponent(String type) {
    return Draggable<String>(
      data: type,
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(type, style: const TextStyle(color: Colors.white)),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text(type),
          trailing: const Icon(Icons.drag_indicator),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      painter: GridPainter(
        gridSize: gridSize,
        color: Colors.grey.withOpacity(0.2),
      ),
      child: Container(),
    );
  }

  Widget _buildWidget(WidgetData data) {
    final isSelected = selectedWidget == data;

    return Positioned(
      left: data.x,
      top: data.y,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Widget content with long-press to drag
          GestureDetector(
            onTap: () => setState(() => selectedWidget = data),
            onLongPressStart: (_) {
              setState(() => selectedWidget = data); // Ensure it's selected
            },
            onPanUpdate: (details) {
              // Changed from onLongPressMoveUpdate
              setState(() {
                data.x += details.delta.dx;
                data.y += details.delta.dy;
                if (showGrid) {
                  data.x = (data.x / gridSize).round() * gridSize;
                  data.y = (data.y / gridSize).round() * gridSize;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
              child: _buildWidgetContent(data),
            ),
          ),
          // Resize handle
          if (isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    data.width += details.delta.dx;
                    data.height += details.delta.dy;
                    data.width = data.width.clamp(50, double.infinity);
                    data.height = data.height.clamp(30, double.infinity);
                    if (showGrid) {
                      data.width = (data.width / gridSize).round() * gridSize;
                      data.height = (data.height / gridSize).round() * gridSize;
                    }
                  });
                },
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWidgetContent(WidgetData data) {
    switch (data.type) {
      case 'Button':
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: data.color,
            minimumSize: Size(data.width, data.height),
          ),
          child: Text(data.text),
        );
      case 'Text':
        return Container(
          width: data.width,
          height: data.height,
          alignment: Alignment.center,
          child: Text(
            data.text,
            style: TextStyle(fontSize: data.fontSize, color: data.color),
          ),
        );
      case 'TextField':
        return SizedBox(
          width: data.width,
          height: data.height,
          child: TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: data.text,
            ),
          ),
        );
      case 'Container':
        return Container(
          width: data.width,
          height: data.height,
          decoration: BoxDecoration(color: data.color, border: Border.all()),
        );
      case 'AppBar':
        return SizedBox(
          width: data.width,
          height: data.height.clamp(
            56,
            double.infinity,
          ), // Minimum height for AppBar
          child: AppBar(
            title: Text(data.text),
            backgroundColor: data.color,
            elevation: 4,
          ),
        );
      case 'FloatingActionButton':
        return SizedBox(
          width: data.width.clamp(56, double.infinity), // FAB standard size
          height: data.height.clamp(56, double.infinity),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: data.color,
            child: data.text.isNotEmpty
                ? Text(data.text[0]) // Use first letter for FAB
                : const Icon(Icons.add),
          ),
        );
      case 'Image':
        return Container(
          width: data.width,
          height: data.height,
          decoration: BoxDecoration(
            color: data.color.withAlpha(50), // Light background for placeholder
            border: Border.all(),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 32, color: Colors.grey),
          ), // Placeholder for image
        );
      case 'Card':
        return SizedBox(
          width: data.width,
          height: data.height,
          child: Card(
            color: data.color,
            elevation: 4,
            child: Center(
              child: Text(
                data.text.isNotEmpty ? data.text : 'Card',
                style: TextStyle(fontSize: data.fontSize),
              ),
            ),
          ),
        );
      case 'Icon':
        return SizedBox(
          width: data.width,
          height: data.height,
          child: Center(
            child: Icon(
              Icons.star, // Default icon, could be made configurable
              size: data.fontSize * 2, // Scale with fontSize
              color: data.color,
            ),
          ),
        );
      default:
        return Container(
          width: data.width,
          height: data.height,
          color: Colors.grey,
          child: Center(child: Text('Unknown: ${data.type}')),
        );
    }
  }

  Widget _buildPropertiesPanel() {
    return SizedBox(
      width: 250,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Properties', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildTextField(
                'Text',
                selectedWidget!.text,
                (value) => setState(() => selectedWidget!.text = value),
              ),
              _buildTextField('Width', selectedWidget!.width.toString(), (
                value,
              ) {
                final width = double.tryParse(value);
                if (width != null) {
                  setState(() => selectedWidget!.width = width);
                }
              }),
              _buildTextField('Height', selectedWidget!.height.toString(), (
                value,
              ) {
                final height = double.tryParse(value);
                if (height != null) {
                  setState(() => selectedWidget!.height = height);
                }
              }),
              if (selectedWidget!.type == 'Text')
                _buildTextField(
                  'Font Size',
                  selectedWidget!.fontSize.toString(),
                  (value) {
                    final size = double.tryParse(value);
                    if (size != null) {
                      setState(() => selectedWidget!.fontSize = size);
                    }
                  },
                ),
              const SizedBox(height: 16),
              Text('Color', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Colors.primaries.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedWidget!.color = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedWidget!.color == color
                              ? Colors.white
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        onChanged: onChanged,
      ),
    );
  }

  void _addWidget(String type, Offset position) {
    setState(() {
      final widget = WidgetData(type: type, x: position.dx, y: position.dy);
      widgets.add(widget);
      selectedWidget = widget;
    });
  }

  void _showGeneratedCode() {
    final code = StringBuffer();
    code.writeln('Widget build(BuildContext context) {');
    code.writeln('  return Stack(');
    code.writeln('    children: [');

    for (final widget in widgets) {
      code.writeln('      Positioned(');
      code.writeln('        left: ${widget.x},');
      code.writeln('        top: ${widget.y},');
      code.writeln('        child: ${_generateWidgetCode(widget)},');
      code.writeln('      ),');
    }

    code.writeln('    ],');
    code.writeln('  );');
    code.writeln('}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Code'),
        content: SingleChildScrollView(
          child: SelectableText(code.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateWidgetCode(WidgetData widget) {
    switch (widget.type) {
      case 'Button':
        return '''ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(${widget.color.value}),
            minimumSize: Size(${widget.width}, ${widget.height}),
          ),
          child: Text('${widget.text}'),
        )''';
      case 'Text':
        return '''Container(
          width: ${widget.width},
          height: ${widget.height},
          alignment: Alignment.center,
          child: Text(
            '${widget.text}',
            style: TextStyle(
              fontSize: ${widget.fontSize},
              color: Color(${widget.color.value}),
            ),
          ),
        )''';
      case 'TextField':
        return '''SizedBox(
          width: ${widget.width},
          height: ${widget.height},
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '${widget.text}',
            ),
          ),
        )''';
      case 'Container':
        return '''Container(
          width: ${widget.width},
          height: ${widget.height},
          decoration: BoxDecoration(
            color: Color(${widget.color.value}),
            border: Border.all(),
          ),
        )''';
      default:
        return 'Container()';
    }
  }
}

class WidgetData {
  String type;
  double x;
  double y;
  double width;
  double height;
  String text;
  Color color;
  double fontSize;

  WidgetData({
    required this.type,
    required this.x,
    required this.y,
    this.width = 120,
    this.height = 40,
    this.text = '',
    this.color = Colors.blue,
    this.fontSize = 14,
  }) {
    switch (type) {
      case 'Button':
        text = 'Button';
        break;
      case 'Text':
        text = 'Text';
        break;
      case 'TextField':
        text = 'Label';
        break;
      case 'AppBar':
        text = 'App Bar';
        width = 300; // Wider default for AppBar
        height = 56; // Standard AppBar height
        break;
      case 'FloatingActionButton':
        text = 'FAB';
        width = 56; // Standard FAB size
        height = 56;
        break;
      case 'Image':
        text = 'Image';
        width = 100;
        height = 100;
        break;
      case 'Card':
        text = 'Card';
        width = 150;
        height = 100;
        break;
      case 'Icon':
        text = 'Icon';
        width = 40;
        height = 40;
        break;
    }
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;

  GridPainter({required this.gridSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
