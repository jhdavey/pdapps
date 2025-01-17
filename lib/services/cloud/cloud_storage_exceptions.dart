class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateNoteException extends CloudStorageExceptions {}

class CouldNotGetAllNotesException extends CloudStorageExceptions {}

class CouldNotUpdateNote extends CloudStorageExceptions {}

class CouldNotDeleteNote extends CloudStorageExceptions {}
