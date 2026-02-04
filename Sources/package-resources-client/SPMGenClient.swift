public struct PackageResourcesClient {
  public init(
    processResources: Operations.ProcessResources
  ) {
    self.processResources = processResources
  }

  public var processResources: Operations.ProcessResources
}
