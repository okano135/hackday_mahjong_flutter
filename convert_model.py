# Model conversion script for mahjong tiles
# Run this if you have a .pt YOLO model file

from ultralytics import YOLO

def convert_pt_to_tflite(model_path, output_path):
    """
    Convert YOLO .pt model to TensorFlow Lite format
    """
    # Load the YOLO model
    model = YOLO(model_path)
    
    # Export to TensorFlow Lite
    model.export(format='tflite', imgsz=640, int8=False)
    print(f"Model converted and saved to {output_path}")

def convert_pt_to_onnx(model_path):
    """
    Convert YOLO .pt model to ONNX format (alternative)
    """
    model = YOLO(model_path)
    model.export(format='onnx', imgsz=640)
    print("Model converted to ONNX format")

if __name__ == "__main__":
    # Example usage:
    # convert_pt_to_tflite('mahjong_model.pt', 'mahjong_model.tflite')
    
    print("To use this script:")
    print("1. Place your mahjong .pt model file in this directory")
    print("2. Update the file paths below")
    print("3. Run: python convert_model.py")
    
    # Uncomment and modify these lines when you have the model:
    # convert_pt_to_tflite('your_mahjong_model.pt', 'assets/models/mahjong_model.tflite')
