## Contrib Operator Schemas
*This file is automatically generated from the
            [def files](/onnxruntime/core/graph/contrib_ops/contrib_defs.cc) via [this script](/onnxruntime/python/tools/gen_doc.py).
            Do not modify directly and instead edit operator definitions.*

* com.microsoft
  * <a href="#com.microsoft.AttnLSTM">com.microsoft.AttnLSTM</a>
  * <a href="#com.microsoft.ConvInteger">com.microsoft.ConvInteger</a>
  * <a href="#com.microsoft.DequantizeLinear">com.microsoft.DequantizeLinear</a>
  * <a href="#com.microsoft.ExpandDims">com.microsoft.ExpandDims</a>
  * <a href="#com.microsoft.FusedConv">com.microsoft.FusedConv</a>
  * <a href="#com.microsoft.FusedGemm">com.microsoft.FusedGemm</a>
  * <a href="#com.microsoft.GatherND">com.microsoft.GatherND</a>
  * <a href="#com.microsoft.MatMulInteger">com.microsoft.MatMulInteger</a>
  * <a href="#com.microsoft.MaxpoolWithMask">com.microsoft.MaxpoolWithMask</a>
  * <a href="#com.microsoft.MurmurHash3">com.microsoft.MurmurHash3</a>
  * <a href="#com.microsoft.NonMaxSuppression">com.microsoft.NonMaxSuppression</a>
  * <a href="#com.microsoft.QLinearConv">com.microsoft.QLinearConv</a>
  * <a href="#com.microsoft.QLinearMatMul">com.microsoft.QLinearMatMul</a>
  * <a href="#com.microsoft.QuantizeLinear">com.microsoft.QuantizeLinear</a>
  * <a href="#com.microsoft.ROIAlign">com.microsoft.ROIAlign</a>
  * <a href="#com.microsoft.Range">com.microsoft.Range</a>
  * <a href="#com.microsoft.ReduceSumInteger">com.microsoft.ReduceSumInteger</a>
  * <a href="#com.microsoft.SampleOp">com.microsoft.SampleOp</a>
  * <a href="#com.microsoft.Tokenizer">com.microsoft.Tokenizer</a>
  * <a href="#com.microsoft.WordConvEmbedding">com.microsoft.WordConvEmbedding</a>

## com.microsoft
### <a name="com.microsoft.AttnLSTM"></a><a name="com.microsoft.attnlstm">**com.microsoft.AttnLSTM**</a>

  Computes an one-layer RNN where its RNN Cell is an AttentionWrapper wrapped a LSTM Cell. The RNN layer
  contains following basic component: LSTM Cell, Bahdanau Attention Mechanism, AttentionWrapp.
  
  Activation functions:
  
    Relu(x)                - max(0, x)
  
    Tanh(x)                - (1 - e^{-2x})/(1 + e^{-2x})
  
    Sigmoid(x)             - 1/(1 + e^{-x})
  
    (NOTE: Below are optional)
  
    Affine(x)              - alpha*x + beta
  
    LeakyRelu(x)           - x if x >= 0 else alpha * x
  
    ThresholdedRelu(x)     - x if x >= alpha else 0
  
    ScaledTanh(x)          - alpha*Tanh(beta*x)
  
    HardSigmoid(x)         - min(max(alpha*x + beta, 0), 1)
  
    Elu(x)                 - x if x >= 0 else alpha*(e^x - 1)
  
    Softsign(x)            - x/(1 + |x|)
  
    Softplus(x)            - log(1 + e^x)
  
    Softmax(x)             - exp(x) / sum(exp(x))
  
  Bahdanau Attention Mechanism:
      `M` -  Memory tensor.
  
      `VALUES` - masked Memory by its real sequence length.
  
      `MW` - Memory layer weight.
  
      `KEYS` - Processed memory tensor by the memory layer.
               KEYS = M * MW
  
      `Query` - Query tensor, normally at specific time step in sequence.
  
      `QW` - Query layer weight in the attention mechanism
  
      `PQ` - processed query,  = `Query` * `QW`
  
      `V' - attention vector
  
      `ALIGN` - calculated alignment based on Query and KEYS
          ALIGN = softmax(reduce_sum(`V` * Tanh(`KEYS` + `PQ`)))
  
      `CONTEXT` - context based on `ALIGN` and `VALUES`
          CONTEXT = `ALIGN` * `VALUES`
  
  
  LSTM Cell:
    `X` - input tensor concat with attention state in the attention wrapper
  
    `i` - input gate
  
    `o` - output gate
  
    `f` - forget gate
  
    `c` - cell gate
  
    `t` - time step (t-1 means previous time step)
  
    `W[iofc]` - W parameter weight matrix for input, output, forget, and cell gates
  
    `R[iofc]` - R recurrence weight matrix for input, output, forget, and cell gates
  
    `Wb[iofc]` - W bias vectors for input, output, forget, and cell gates
  
    `Rb[iofc]` - R bias vectors for input, output, forget, and cell gates
  
    `P[iof]`  - P peephole weight vector for input, output, and forget gates
  
    `WB[iofc]` - W parameter weight matrix for backward input, output, forget, and cell gates
  
    `RB[iofc]` - R recurrence weight matrix for backward input, output, forget, and cell gates
  
    `WBb[iofc]` - W bias vectors for backward input, output, forget, and cell gates
  
    `RBb[iofc]` - R bias vectors for backward input, output, forget, and cell gates
  
    `PB[iof]`  - P peephole weight vector for backward input, output, and forget gates
  
    `H` - Hidden state
  
    `num_directions` - 2 if direction == bidirectional else 1
  
    Equations (Default: f=Sigmoid, g=Tanh, h=Tanh):
  
      - it = f(Xt*(Wi^T) + Ht-1*(Ri^T) + Pi (.) Ct-1 + Wbi + Rbi)
  
      - ft = f(Xt*(Wf^T) + Ht-1*(Rf^T) + Pf (.) Ct-1 + Wbf + Rbf)
  
      - ct = g(Xt*(Wc^T) + Ht-1*(Rc^T) + Wbc + Rbc)
  
      - Ct = ft (.) Ct-1 + it (.) ct
  
      - ot = f(Xt*(Wo^T) + Ht-1*(Ro^T) + Po (.) Ct + Wbo + Rbo)
  
      - Ht = ot (.) h(Ct)
  
  
  AttentionWrapp Notations:
    `lstm()' - wrapped inner cell.
             Ht, Ct = lstm(concat(Xt, ATTNt-1), Ct-1)
  
    `am()` - attention mechanism the wrapper used.
             CONTEXTt, ALIGNt = am(Ht, ALIGNt-1)
  
    `AW` - attention layer weights, optional.
  
    `ATTN` - attention state, initial is zero. If `AW` provided, it is the output of the attention layer,
                  ATTNt = concat(Ht, CONTEXTt) * AW
             otherwise,
                  ATTNt = CONTEXTt
  
  RNN layer output:
    `Y` - if needed is the sequence of Ht from lstm cell.
  
    `Y_h` - is the last valid H from lstm cell.
  
    `Y_c` - is the last valid C from lstm cell.
  

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>activation_alpha</tt> : list of floats</dt>
<dd>Optional scaling values used by some activation functions. The values are consumed in the order of activation functions, for example (f, g, h) in LSTM. Default values are the same as of corresponding ONNX operators.For example with LeakyRelu, the default alpha is 0.01.</dd>
<dt><tt>activation_beta</tt> : list of floats</dt>
<dd>Optional scaling values used by some activation functions. The values are consumed in the order of activation functions, for example (f, g, h) in LSTM. Default values are the same as of corresponding ONNX operators.</dd>
<dt><tt>activations</tt> : list of strings</dt>
<dd>A list of 3 (or 6 if bidirectional) activation functions for input, output, forget, cell, and hidden. The activation functions must be one of the activation functions specified above. Optional: See the equations for default if not specified.</dd>
<dt><tt>clip</tt> : float</dt>
<dd>Cell clip threshold. Clipping bounds the elements of a tensor in the range of [-threshold, +threshold] and is applied to the input of activations. No clip if not specified.</dd>
<dt><tt>direction</tt> : string</dt>
<dd>Specify if the RNN is forward, reverse, or bidirectional. Must be one of forward (default), reverse, or bidirectional.</dd>
<dt><tt>hidden_size</tt> : int</dt>
<dd>Number of neurons in the hidden layer.</dd>
<dt><tt>input_forget</tt> : int</dt>
<dd>Couple the input and forget gates if 1, default 0.</dd>
</dl>

#### Inputs (3 - 14)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Outputs (0 - 3)

<dl>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.ConvInteger"></a><a name="com.microsoft.convinteger">**com.microsoft.ConvInteger**</a>

  The integer convolution operator consumes an input tensor, a filter, and a padding value,
   and computes the output. The production MUST never overflow. The accumulation may overflow
   if and only if in 32 bits.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>auto_pad</tt> : string</dt>
<dd>auto_pad must be either NOTSET, SAME_UPPER, SAME_LOWER or VALID. Where default value is NOTSET, which means explicit padding is used. SAME_UPPER or SAME_LOWER mean pad the input so that the output size match the input.In case of odd number add the extra padding at the end for SAME_UPPER and at the beginning for SAME_LOWER. VALID mean no padding.</dd>
<dt><tt>dilations</tt> : list of ints</dt>
<dd>dilation value along each axis of the filter. If not present, the dilation defaults to 1 along each axis.</dd>
<dt><tt>group</tt> : int</dt>
<dd>number of groups input channels and output channels are divided into. default is 1.</dd>
<dt><tt>kernel_shape</tt> : list of ints</dt>
<dd>The shape of the convolution kernel. If not present, should be inferred from input 'w'.</dd>
<dt><tt>pads</tt> : list of ints</dt>
<dd>Padding for the beginning and ending along each axis, it can take any value greater than or equal to 0.The value represent the number of pixels added to the beginning and end part of the corresponding axis.`pads` format should be as follow [x1_begin, x2_begin...x1_end, x2_end,...], where xi_begin the number ofpixels added at the beginning of axis `i` and xi_end, the number of pixels added at the end of axis `i`.This attribute cannot be used simultaneously with auto_pad attribute. If not present, the padding defaultsto 0 along start and end of each axis.</dd>
<dt><tt>strides</tt> : list of ints</dt>
<dd>Stride along each axis. If not present, the stride defaults to 1 along each axis.</dd>
</dl>

#### Inputs (2 - 4)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.DequantizeLinear"></a><a name="com.microsoft.dequantizelinear">**com.microsoft.DequantizeLinear**</a>

  The linear de-quantization operator. It consumes a quantized data, a scale, a zero point and computes the full precision data.
  The dequantization formula is y = (x - x_zero_point) * x_scale.
  Scale and zero point must have same shape. They must be either scalar (per tensor) or 1-D tensor (per 'axis').

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>axis</tt> : int</dt>
<dd>the axis along which same quantization parameters are applied. It's optional. If it's not specified, it means per-tensor quantization and input 'x_scale' and 'x_zero_point' must be scalars. If it's specified, it means per 'axis' quantization and input 'x_scale' and 'x_zero_point' must be 1-D tensors.</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.ExpandDims"></a><a name="com.microsoft.expanddims">**com.microsoft.ExpandDims**</a>

  ExpandDims echo operator.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.FusedConv"></a><a name="com.microsoft.fusedconv">**com.microsoft.FusedConv**</a>

  The fused convolution operator schema is the same as Conv besides it includes an attribute
  activation.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>activation</tt> : string</dt>
<dd></dd>
<dt><tt>alpha</tt> : float</dt>
<dd></dd>
<dt><tt>auto_pad</tt> : string</dt>
<dd></dd>
<dt><tt>dilations</tt> : list of ints</dt>
<dd></dd>
<dt><tt>group</tt> : int</dt>
<dd></dd>
<dt><tt>kernel_shape</tt> : list of ints</dt>
<dd></dd>
<dt><tt>pads</tt> : list of ints</dt>
<dd></dd>
<dt><tt>strides</tt> : list of ints</dt>
<dd></dd>
</dl>

#### Inputs (2 - 3)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.FusedGemm"></a><a name="com.microsoft.fusedgemm">**com.microsoft.FusedGemm**</a>

  The FusedGemm operator schema is the same as Gemm besides it includes attributes
  activation and leaky_relu_alpha.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>activation</tt> : string</dt>
<dd></dd>
<dt><tt>alpha</tt> : float</dt>
<dd>Scalar multiplier for the product of input tensors A * B.</dd>
<dt><tt>beta</tt> : float</dt>
<dd>Scalar multiplier for input tensor C.</dd>
<dt><tt>leaky_relu_alpha</tt> : float</dt>
<dd></dd>
<dt><tt>transA</tt> : int</dt>
<dd>Whether A should be transposed</dd>
<dt><tt>transB</tt> : int</dt>
<dd>Whether B should be transposed</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.GatherND"></a><a name="com.microsoft.gathernd">**com.microsoft.GatherND**</a>

  Given `data` tensor of rank r >= 1, and `indices` tensor of rank q >= 1, gather
  slices of `data` into an output tensor of rank q - 1 + r - indices[-1].
  Example 1:
    data    = [[0,1],[2,3]]
    indices = [[0,0],[1,1]]
    output  = [0,3]
  Example 2:
    data    = [[0,1],[2,3]]
    indices = [[1],[0]]
    output  = [[2,3],[0,1]]
  Example 3:
    data    = [[[0,1],[2,3]],[[4,5],[6,7]]]
    indices = [[0,1],[1,0]]
    output  = [[2,3],[4,5]]
  Example 4:
    data    = [[[0,1],[2,3]],[[4,5],[6,7]]]
    indices = [[[0,1]],[[1,0]]]
    output  = [[[2,3]],[[4,5]]]

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.MatMulInteger"></a><a name="com.microsoft.matmulinteger">**com.microsoft.MatMulInteger**</a>

  Matrix product that behaves like numpy.matmul: https://docs.scipy.org/doc/numpy-1.13.0/reference/generated/numpy.matmul.html.
   The production MUST never overflow. The accumulation may overflow if and only if in 32 bits.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Inputs (2 - 4)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.MaxpoolWithMask"></a><a name="com.microsoft.maxpoolwithmask">**com.microsoft.MaxpoolWithMask**</a>

  For internal use.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>auto_pad</tt> : string</dt>
<dd></dd>
<dt><tt>kernel_shape</tt> : list of ints</dt>
<dd></dd>
<dt><tt>pads</tt> : list of ints</dt>
<dd></dd>
<dt><tt>storage_order</tt> : int</dt>
<dd></dd>
<dt><tt>strides</tt> : list of ints</dt>
<dd></dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.MurmurHash3"></a><a name="com.microsoft.murmurhash3">**com.microsoft.MurmurHash3**</a>

  The underlying implementation is MurmurHash3_x86_32 generating low latency 32bits hash suitable for implementing lookup tables, Bloom filters, count min sketch or feature hashing.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>positive</tt> : int</dt>
<dd>If value is 1, output type is uint32_t, else int32_t. Default value is 1.</dd>
<dt><tt>seed</tt> : int</dt>
<dd>Seed for the hashing algorithm, unsigned 32-bit integer, default to 0.</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.NonMaxSuppression"></a><a name="com.microsoft.nonmaxsuppression">**com.microsoft.NonMaxSuppression**</a>

  Pruning away boxes that have high intersection-over-union (IOU) overlap with previously selected boxes.
  Bounding boxes with score less than score_threshold are removed. Bounding boxes are supplied as [y1, x1, y2, x2],
  where (y1, x1) and (y2, x2) are the coordinates of any diagonal pair of box corners and the coordinates can be provided
  as normalized (i.e., lying in the interval [0, 1]) or absolute.
  Note that this algorithm is agnostic to where the origin is in the coordinate system and more generally is invariant to
  orthogonal transformations and translations of the coordinate system;
  thus translating or reflections of the coordinate system result in the same boxes being selected by the algorithm.
  The output of this operation is a set of integers indexing into the input collection of bounding boxes representing the selected boxes.
  The bounding box coordinates corresponding to the selected indices can then be obtained using the gather operation.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>iou_threshold</tt> : float</dt>
<dd>Float representing the threshold for deciding whether boxes overlap too much with respect to IOU. Value range [0, 1]. The default is 0.0</dd>
<dt><tt>max_output_size</tt> : int (required)</dt>
<dd>Integer representing the maximum number of boxes to be selected by non max suppression.</dd>
<dt><tt>pad_to_max_output_size</tt> : int</dt>
<dd>Optional. 1(true) - the output selected_indices is padded to be of length max_output_size. Defaults to 0(false).</dd>
<dt><tt>score_threshold</tt> : float (required)</dt>
<dd>Float tensor representing the threshold for deciding when to remove boxes based on score.</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs (1 - 2)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.QLinearConv"></a><a name="com.microsoft.qlinearconv">**com.microsoft.QLinearConv**</a>

  The convolution operator consumes a quantized input tensor, its scale and zero point,
  a quantized filter, its scale and zero point, and output's scale and zero point,
  and computes the quantized output. Each scale and zero point pair must have same shape.
  It means they must be either scalars (per tensor) or 1-D tensors (per channel).
  The production MUST never overflow. The accumulation may overflow in 32 bits
  if the input is 8 bits or in 64 bits if the input is 16 bits.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>auto_pad</tt> : string</dt>
<dd>auto_pad must be either NOTSET, SAME_UPPER, SAME_LOWER or VALID. Where default value is NOTSET, which means explicit padding is used. SAME_UPPER or SAME_LOWER mean pad the input so that the output size match the input.In case of odd number add the extra padding at the end for SAME_UPPER and at the beginning for SAME_LOWER. VALID mean no padding.</dd>
<dt><tt>dilations</tt> : list of ints</dt>
<dd>dilation value along each axis of the filter. If not present, the dilation defaults to 1 along each axis.</dd>
<dt><tt>group</tt> : int</dt>
<dd>number of groups input channels and output channels are divided into. default is 1.</dd>
<dt><tt>kernel_shape</tt> : list of ints</dt>
<dd>The shape of the convolution kernel. If not present, should be inferred from input 'w'.</dd>
<dt><tt>pads</tt> : list of ints</dt>
<dd>Padding for the beginning and ending along each axis, it can take any value greater than or equal to 0.The value represent the number of pixels added to the beginning and end part of the corresponding axis.`pads` format should be as follow [x1_begin, x2_begin...x1_end, x2_end,...], where xi_begin the number ofpixels added at the beginning of axis `i` and xi_end, the number of pixels added at the end of axis `i`.This attribute cannot be used simultaneously with auto_pad attribute. If not present, the padding defaultsto 0 along start and end of each axis.</dd>
<dt><tt>strides</tt> : list of ints</dt>
<dd>Stride along each axis. If not present, the stride defaults to 1 along each axis.</dd>
</dl>

#### Inputs (8 - 9)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.QLinearMatMul"></a><a name="com.microsoft.qlinearmatmul">**com.microsoft.QLinearMatMul**</a>

  Matrix product that behaves like numpy.matmul: https://docs.scipy.org/doc/numpy-1.13.0/reference/generated/numpy.matmul.html.
  It consumes two quantized input tensors, their scales and zero points, and output's scale and zero point, and computes
  the quantized output. The quantization formula is x_quantized = (x_fp32 / x_scale) + x_zero_point. For (x_fp32 / x_scale),
  it computes the nearest integer value to arg (in floating-point format), rounding halfway cases away from zero.
  Scale and zero point must have same shape. They must be either scalar (per tensor) or 1-D tensor (per row for a and per column for b).
  If scale and zero point are 1D tensor, the number of elements of scale and zero point tensor of input 'a' and output 'y'
  should be equal to the number of rows of input 'a', and the number of elements of scale and zero point tensor of input 'b'
  should be equal to the number of columns of input 'b'. The production MUST never overflow. The accumulation may overflow in 32 bits
  if the input is 8 bits or in 64 bits if the input is 16 bits.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.QuantizeLinear"></a><a name="com.microsoft.quantizelinear">**com.microsoft.QuantizeLinear**</a>

  The linear quantization operator. It consumes a full precision data, a scale, a zero point and computes the quantized data.
  The quantization formula is y = (x / y_scale) + y_zero_point. For (x / y_scale), it computes the nearest integer value to arg (in floating-point format),
   rounding halfway cases away from zero. Scale and zero point must have same shape. They must be either scalar (per tensor) or 1-D tensor (per 'axis').

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>axis</tt> : int</dt>
<dd>The axis along which same quantization parameters are applied. It's optional. If it's not specified, it means per-tensor quantization and input 'x_scale' and 'x_zero_point' must be scalars. If it's specified, it means per 'axis' quantization and input 'x_scale' and 'x_zero_point' must be 1-D tensors.</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.ROIAlign"></a><a name="com.microsoft.roialign">**com.microsoft.ROIAlign**</a>

  Region of Interest (RoI) align operation described in the
    [Mask R-CNN paper](https://arxiv.org/abs/1703.06870).
    RoIAlign consumes an input tensor X and region of interests (rois)
    to apply pooling across each RoI; it produces a 4-D tensor of shape
    (num_rois, C, pooled_h, pooled_w).
  
    RoIAlign is proposed to avoid the misalignment by removing
    quantizations while converting from original image into feature
    map and from feature map into RoI feature; in each ROI bin,
    the value of the sampled locations are computed directly
    through bilinear interpolation.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>mode</tt> : string</dt>
<dd>The pooling method. Two modes are supported: 'avg' and 'max'. Default is 'avg'.</dd>
<dt><tt>pooled_h</tt> : int</dt>
<dd>default 1; Pooled output Y's height.</dd>
<dt><tt>pooled_w</tt> : int</dt>
<dd>default 1; Pooled output Y's width.</dd>
<dt><tt>sampling_ratio</tt> : int</dt>
<dd>Number of sampling points in the interpolation grid used to compute the output value of each pooled output bin. If > 0, then exactly sampling_ratio x sampling_ratio grid points are used. If == 0, then an adaptive number of grid points are used (computed as ceil(roi_width / pooled_w), and likewise for height). Default is 0.</dd>
<dt><tt>spatial_scale</tt> : float</dt>
<dd>Multiplicative spatial scale factor to translate ROI coordinates from their input spatial scale to the scale used when pooling, i.e., spatial scale of the input feature map X relative to the input image. E.g.; default is 1.0f. </dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.Range"></a><a name="com.microsoft.range">**com.microsoft.Range**</a>

  Creates a sequence of numbers that begins at `start` and extends by increments of `delta`
  up to but not including `limit`.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Inputs (2 - 3)

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> (optional) : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.ReduceSumInteger"></a><a name="com.microsoft.reducesuminteger">**com.microsoft.ReduceSumInteger**</a>

  Computes the sum of the low-precision input tensor's element along the provided axes.
  The resulting tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0,
  then the resulting tensor have the reduced dimension pruned. The above behavior is similar to numpy,
  with the exception that numpy default keepdims to False instead of True.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>axes</tt> : list of ints (required)</dt>
<dd>A list of integers, along which to reduce. The default is to reduce over all the dimensions of the input tensor.</dd>
<dt><tt>keepdims</tt> : int (required)</dt>
<dd>Keep the reduced dimension or not, default 1 mean keep reduced dimension.</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.SampleOp"></a><a name="com.microsoft.sampleop">**com.microsoft.SampleOp**</a>

  Sample echo operator.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.Tokenizer"></a><a name="com.microsoft.tokenizer">**com.microsoft.Tokenizer**</a>

  Tokenizer divides each string in X into a vector of strings along the last axis. Allowed input shapes are [C] and [N, C].
    If the maximum number of tokens found per input string is D, the output shape would be [N, C, D] when input shape is [N, C].
    Similarly, if input shape is [C] then the output should be [C, D]. Tokenizer has two different operation modes.
    The first mode is selected when "tokenexp" is not set and "separators" is set. If "tokenexp" is set and "separators" is not set,
    the second mode will be used. The first mode breaks each input string into tokens by removing separators.
  
    Let's assume "separators" is [" "] and consider an example.
    If input is
  
    ["Hello World", "I love computer science !"] whose shape is [2],
  
    then the output would be
  
   [["Hello", "World", padvalue, padvalue, padvalue],
   ["I", "love", "computer", "science", "!"]]
  
   whose shape is [2, 5] because you can find at most 5 tokens per input string.
   Note that the input at most can have two axes, so 3-D and higher dimension are not supported.
  
   For each input string, the second mode searches matches of "tokenexp" and each match will be a token in Y.
   The matching of "tokenexp" is conducted greedily (i.e., a match should be as long as possible).
   This operator searches for the first match starting from the beginning of the considered string,
   and then launches another search starting from the first remained character after the first matched token.
   If no match found, this operator will remove the first character from the remained string and do another search.
   This procedure will be repeated until reaching the end of the considered string.
  
    Let's consider another example to illustrate the effect of setting "mark" to true.
    If input is ["Hello", "World"],
    then the corresponding output would be [0x02, "Hello", "World", 0x03].
    This implies that if mark is true, [C]/[N, C] - input's output shape becomes [C, D+2]/[N, C, D+2].

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>mark</tt> : int (required)</dt>
<dd>Boolean whether to mark the beginning/end character with start of text character (0x02)/end of text character (0x03).</dd>
<dt><tt>mincharnum</tt> : int (required)</dt>
<dd>Minimum number of characters allowed in the output. For example, if mincharnum is 2, tokens such as "A" and "B" would be ignored</dd>
<dt><tt>pad_value</tt> : string (required)</dt>
<dd>The string used to pad output tensors when the tokens extracted doesn't match the maximum number of tokens found. If start/end markers are needed, padding will appear outside the markers.</dd>
<dt><tt>separators</tt> : list of strings</dt>
<dd>an optional list of strings (type: AttributeProto::STRINGS), each single string in this attribute is a separator. Two consecutive segments in X connected by a separator would be divided into two tokens. For example, if the input is "Hello World!" and this attribute contains only one space character, the corresponding output would be ["Hello", "World!"]. To achieve character-level tokenization, one should set the separators to [""], which contains only one empty string. If 'separators' is a L-element array, there will be L rounds of tokenization using one stop word. More specifically, in the first round, the first element in 'separators' is used to tokenize each string in the input. Then, the second element in 'separators' will be used to tokenize the resulted strings produced at the first round.</dd>
<dt><tt>tokenexp</tt> : string</dt>
<dd>An optional string. Token's regular expression in basic POSIX format (http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_03). If set, tokenizer may produce tokens matching the specified pattern. Note that one and only of 'tokenexp' and 'separators' should be set.</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>


### <a name="com.microsoft.WordConvEmbedding"></a><a name="com.microsoft.wordconvembedding">**com.microsoft.WordConvEmbedding**</a>

  The WordConvEmbedding takes in a batch of sequence words and embed each word to a vector.

#### Version

This version of the operator has been available since version 1 of the 'com.microsoft' operator set.

#### Attributes

<dl>
<dt><tt>char_embedding_size</tt> : int</dt>
<dd>Integer representing the embedding vector size for each char.If not provide, use the char embedding size of embedding vector.</dd>
<dt><tt>conv_window_size</tt> : int</dt>
<dd>This operator applies convolution to word from left to right with window equal to conv_window_size and stride to 1.Take word 'example' for example, with conv_window_size equal to 2, conv is applied to [ex],[xa], [am], [mp]...If not provide, use the first dimension of conv kernal shape.</dd>
<dt><tt>embedding_size</tt> : int</dt>
<dd>Integer representing the embedding vector size for each word.If not provide, use the fileter size of conv weight</dd>
</dl>

#### Inputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Outputs

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

#### Type Constraints

<dl>
<dt><tt></tt> : </dt>
<dd></dd>
<dt><tt></tt> : </dt>
<dd></dd>
</dl>

