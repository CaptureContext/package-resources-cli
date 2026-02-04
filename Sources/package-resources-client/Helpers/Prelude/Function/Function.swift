public typealias EndoFunctionOf<T> = Function<T, T>

public typealias FunctionOf<F: FunctionSignatureProtocol> = Function<
  F.Input,
  F.Output
>

public protocol Function<Input, Output>: FunctionSignatureProtocol {
  typealias SyncSignature = SyncFunctionSignature<Input, Output>
  typealias AsyncSignature = AsyncFunctionSignature<Input, Output>

  init(_ call: @escaping SyncSignature)
  func callAsFunction(_ input: Input) async -> Output
}

// MARK: Calls

extension Function where Input == Void {
  @inlinable
  public func callAsFunction() async -> Output {
    return await callAsFunction(())
  }
}
