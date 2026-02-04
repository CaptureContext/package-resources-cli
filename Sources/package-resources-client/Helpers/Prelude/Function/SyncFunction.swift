public typealias SyncFunctionEndoOf<T> = SyncFunction<T, T>

public typealias SyncFunctionOf<F: FunctionSignatureProtocol> = SyncFunction<
  F.Input,
  F.Output
>

public protocol SyncFunction<Input, Output>: Function {
  func callAsFunction(_ input: Input) -> Output
}

// MARK: Type erasure

extension SyncFunction {
  @inlinable
  public func eraseToSyncFunction() -> some SyncFunction<Input, Output> { self }
}

// MARK: Calls

extension SyncFunction where Input == Void {
  @inlinable
  public func callAsFunction() -> Output {
    return callAsFunction(())
  }
}

// MARK: Async

extension SyncFunction {
  @inlinable
  public func callAsFunction(_ input: Input) async -> Output {
    return _call(input)
  }

  @usableFromInline
  internal func _call(_ input: Input) -> Output {
    callAsFunction(input)
  }
}
