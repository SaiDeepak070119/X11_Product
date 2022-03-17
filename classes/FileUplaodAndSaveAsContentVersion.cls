public without sharing class FileUplaodAndSaveAsContentVersion {
    
    @testVIsible
    public static void saveFileData(String fileInfoWrapperdata, String objectId){
        
        list<FileInfoWrapper>fileInfoWarpperObj = new list<FileInfoWrapper>();
        
        fileInfoWarpperObj = (list<FileInfoWrapper>)JSON.deserialize(fileInfoWrapperdata, list<FileInfoWrapper>.class);
        
        list<Attachment> aatachList = new list<Attachment>();
        aatachList = createAttachment(fileInfoWarpperObj,objectId);
        insert aatachList;
        
    }

    @testVIsible
    private static list<Attachment> createAttachment(list<FileInfoWrapper>fileInfoWarpperObj,String objectId) {
         list<Attachment>listOfAttachment = new list<Attachment>();
        for(FileInfoWrapper fw : fileInfoWarpperObj){

           
            Attachment att = new Attachment();
            String base64 = fw.fileData;
            base64 = base64.SubStringAfter(',');
           // system.debug('----base64'+base64);
            att.body = EncodingUtil.base64Decode(base64);
            att.Name = fw.filename;
            att.ParentId = objectId;
            listOfAttachment.add(att);
        }
        return listOfAttachment;
       
    }
    @testVIsible
    public class FileInfoWrapper{
        public String fileName;
        public String fileType;
        public String fileData;
    }
}