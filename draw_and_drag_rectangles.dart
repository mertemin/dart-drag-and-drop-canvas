import 'dart:html';

class Shape {
  var STROKE_STYLE = "red";
  
  CanvasRenderingContext2D context;
  num x, y, width, height;
  
  Shape(context, x, y, width, height, fillStyle) {
    this.context = context;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.context.fillStyle = fillStyle;
    this.context.strokeStyle = this.STROKE_STYLE;
  }
  
  void draw() {
    this.context.fillRect(this.x, this.y, this.width, this.height);
  }
  
  void select() {
    this.context.strokeRect(this.x, this.y, this.width, this.height);
  }
  
  void deselect() {
    this.context.clearRect(this.x-1, this.y-1, this.width+2, this.height+2);
    this.draw();
  }
  
  void move(num x, num y) {
    this.x = x;
    this.y = y;
  }
  
  bool contains(num x, num y) {
    return this.x <= x && x <= this.x + this.width && this.y <= y && y <= this.y + this.height;
  }
}

class Canvas {
  /*
   * Constants
   */
  int WIDTH = 60, HEIGHT = 40;
  
  /*
   * Class variables
   */
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  List<Shape> shapes;
  Shape selectedShape;
  bool dragging;
  num dragOffsetX, dragOffsetY;
  
  Canvas(canvas_id) {
    this.canvas = document.querySelector(canvas_id);
    this.context = this.canvas.getContext("2d");
    
    this.shapes = new List<Shape>();
    this.selectedShape = null;
    this.dragging = false;
    
    this.canvas.onDoubleClick.listen((MouseEvent e) => addNewShape(e));
    this.canvas.onMouseDown.listen((MouseEvent e) => selectShape(e));
    this.canvas.onMouseMove.listen((MouseEvent e) => moveShape(e));
    this.canvas.onMouseUp.listen((MouseEvent e) => moveCompleted(e));
  }
  
  void addNewShape(MouseEvent e) {
    num x = e.offset.x - WIDTH/2;
    num y = e.offset.y - HEIGHT/2;
    
    Shape newShape = new Shape(this.context, x, y, WIDTH, HEIGHT, "#F8E0E6");
    newShape.draw();
    this.shapes.add(newShape);
  }
  
  void selectShape(MouseEvent e) {
    // If we already selected a shape, then deselect it
    if (this.selectedShape != null) {
      this.deselectShape();
    }
    
    int numberOfShapes = shapes.length;
    for (int i = numberOfShapes-1; i >= 0; i--) {
      if (this.shapes[i].contains(e.offset.x, e.offset.y)) {
        this.dragging = true;
        this.selectedShape = this.shapes[i];
        this.selectedShape.select();
        this.dragOffsetX = e.offset.x - this.selectedShape.x;
        this.dragOffsetY = e.offset.y - this.selectedShape.y;
        return;
      }
    }
    
    // Failed to select a shape
    // So deselect if any shape is selected
    if (this.selectedShape != null) {
      this.deselectShape();
    }
  }
  
  void deselectShape() {
    this.selectedShape.deselect();
    this.selectedShape = null;
  }
  
  void moveShape(MouseEvent e) {
    if (this.dragging) {
      this.selectedShape.move(e.offset.x - this.dragOffsetX, e.offset.y - this.dragOffsetY);
      this.redraw();
    }
  }
  
  void moveCompleted(MouseEvent e) {
    this.dragging = false;
  }
  
  void redraw() {
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    for (Shape shape in this.shapes) {
      shape.draw();
    }
    
    if (selectedShape != null) {
      this.selectedShape.select();
    }
  }
}

void main() {
  Canvas c = new Canvas("#app_container");
}