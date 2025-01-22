class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateBuildException extends CloudStorageExceptions {}

class CouldNotGetAllBuildsException extends CloudStorageExceptions {}

class CouldNotUpdateBuild extends CloudStorageExceptions {}

class CouldNotDeleteBuild extends CloudStorageExceptions {}
