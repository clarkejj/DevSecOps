// aws-s3-list.java
// Return the complete list of all the objects inside given S3 directory.
// From http://codeflex.co/get-list-of-objects-from-s3-directory/

public List<String> getObjectslistFromFolder(String bucketName, String folderKey) {
   
  ListObjectsRequest listObjectsRequest = 
                                new ListObjectsRequest()
                                      .withBucketName(bucketName)
                                      .withPrefix(folderKey + "/");
 
  List<String> keys = new ArrayList<>();
 
  ObjectListing objects = s3Client.listObjects(listObjectsRequest);
  for (;;) {
    List<S3ObjectSummary> summaries = objects.getObjectSummaries();
    if (summaries.size() < 1) {
      break;
    }
    summaries.forEach(s -> keys.add(s.getKey()));
    objects = s3Client.listNextBatchOfObjects(objects);
  }
 
  return keys;
}