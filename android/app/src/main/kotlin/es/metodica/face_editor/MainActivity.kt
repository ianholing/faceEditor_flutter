package es.metodica.face_editor

import android.os.Bundle
import android.util.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.Tensor
import java.io.FileInputStream
import java.io.IOException
import java.nio.channels.FileChannel
import java.util.*


class MainActivity : FlutterActivity() {
    private val CHANNEL = "es.metodica.face_editor/tflite"
    private var tflite: Interpreter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "inference") {
                val arguments = call.arguments as HashMap<*, *>
                try {
                    inference(arguments, result)
                } catch (e: java.lang.Exception) {
                    result.error("Failed to run model", e.message, e)
                }
            } else if (call.method == "load_model") {
                try {
                    val res: String = loadModel(call.arguments as HashMap<*, *>)
                    result.success(res)
                } catch (e: Exception) {
                    result.error("Failed to load model", e.message, e)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @Throws(IOException::class)
    private fun loadModel(args: HashMap<*, *>): String {
        val modelFilename: String = args.get("model").toString()
        val fileDescriptor = assets.openFd("flutter_assets/$modelFilename")
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel: FileChannel = inputStream.getChannel()
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        val mappedByteBuffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
        tflite = Interpreter(mappedByteBuffer)
        return "success"
    }

    private fun inference(args: HashMap<*, *>, result: MethodChannel.Result) {
        val tensor: Tensor = tflite!!.getInputTensor(0)
        val shape = tensor?.shape()

        val inp = Array(shape[0]) { Array(shape[1]) { Array(shape[2]) { FloatArray(shape[3]) } } }
        var out = Array(shape[0]) { Array(shape[1]) { Array(shape[2]) { FloatArray(shape[3]) } } }
        val flatArray = args["input"] as ArrayList<*>
        val flatReturn = DoubleArray(shape[1] * shape[2] * shape[3])

        var iz = 0
        var iy = 0
        var ix = 0
        Log.d("FACE EDITOR", "TOTAL LENGTH = " + flatArray.size)
        for (i in 0 until shape[1] * shape[2] * shape[3] - 1) {
            val value = (flatArray[i] as Double).toFloat()
            //Log.d("FACE EDITOR", "ARRAY POSITION: ($ix, $iy, $iz), INDEX: $i, VALUE: $value")
            inp[0][ix][iy][iz] = value
            iz++
            if (iz != 0 && iz % 3 == 0) { iy++; iz = 0 }
            if (iy != 0 && iy % 256 == 0) { ix++; iy = 0 }
        }
        tflite?.run(inp, out)

        iz = 0; iy = 0; ix = 0
        for (i in 0 until shape[1] * shape[2] * shape[3] - 1) {
            //Log.d("FACE EDITOR", "ARRAY POSITION: ($ix, $iy, $iz), INDEX: $i, VALUE: $value")
            flatReturn[i] = out[0][ix][iy][iz].toDouble()
            iz++
            if (iz != 0 && iz % 3 == 0) { iy++; iz = 0 }
            if (iy != 0 && iy % 256 == 0) { ix++; iy = 0 }
        }
        result.success(flatReturn)
    }

//    @Throws(IOException::class)
//    fun feedInputTensor(bitmapRaw: Bitmap, mean: Float, std: Float): ByteBuffer? {
//        val tensor: Tensor = tflite?.getInputTensor(0) ?:
//        val shape = tensor.shape()
//        inputSize = shape[1]
//        val inputChannels = shape[3]
//        val bytePerChannel = if (tensor.dataType() == DataType.UINT8) 1 else BYTES_PER_CHANNEL
//        val imgData: ByteBuffer = ByteBuffer.allocateDirect(1 * inputSize * inputSize * inputChannels * bytePerChannel)
//        imgData.order(ByteOrder.nativeOrder())
//        var bitmap = bitmapRaw
//        if (bitmapRaw.width != inputSize || bitmapRaw.height != inputSize) {
//            val matrix: Matrix = getTransformationMatrix(bitmapRaw.width, bitmapRaw.height,
//                    inputSize, inputSize, false)
//            bitmap = Bitmap.createBitmap(inputSize, inputSize, Bitmap.Config.ARGB_8888)
//            val canvas = Canvas(bitmap)
//            canvas.drawBitmap(bitmapRaw, matrix, null)
//        }
//        if (tensor.dataType() == DataType.FLOAT32) {
//            for (i in 0 until inputSize) {
//                for (j in 0 until inputSize) {
//                    val pixelValue = bitmap.getPixel(j, i)
//                    imgData.putFloat(((pixelValue shr 16 and 0xFF) - mean) / std)
//                    imgData.putFloat(((pixelValue shr 8 and 0xFF) - mean) / std)
//                    imgData.putFloat(((pixelValue and 0xFF) - mean) / std)
//                }
//            }
//        } else {
//            for (i in 0 until inputSize) {
//                for (j in 0 until inputSize) {
//                    val pixelValue = bitmap.getPixel(j, i)
//                    imgData.put((pixelValue shr 16 and 0xFF).toByte())
//                    imgData.put((pixelValue shr 8 and 0xFF).toByte())
//                    imgData.put((pixelValue and 0xFF).toByte())
//                }
//            }
//        }
//        return imgData
//    }
}
