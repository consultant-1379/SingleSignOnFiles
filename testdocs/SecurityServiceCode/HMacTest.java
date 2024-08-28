/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package hmactest;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.security.InvalidKeyException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.apache.commons.codec.binary.Hex;
import javax.crypto.Mac;
import java.util.Date;
import org.apache.commons.codec.binary.Base64;
/**
 *
 * @author EADASZI
 */
public class HMacTest {

    /**
     * @param args the command line arguments
     */
    static int Counter;
    
  
    public static void main(String[] args)throws NoSuchAlgorithmException,
			KeyManagementException,
			 InvalidKeyException,
			IllegalBlockSizeException, BadPaddingException, UnsupportedEncodingException, NoSuchPaddingException {
         
        int counterValue = new HMacTest().createCounter();
        //SessionKey
        byte[] sessionKey = new HMacTest().getSessionKey(counterValue);
        System.out.println("getSessionKey Key : " + sessionKey);  
        
        //22657565-PPQoyvGZ03HJ1n2aPE6ZzYN041XwsNfhZKdzcjHC0WM=
        //
        //
        
        String macData = "eeijgay" + counterValue;
        
        //
        //
        
        System.out.println("Username + Counter : " + macData);
        
        //Define sha256 for hMAC algorithm
        Mac mac;
        
        String str = "";
        byte[] hexB = null;
        byte[] doFinal = null;
		try {
			mac = Mac.getInstance("HmacSHA256");      
        
	        // Convert data into byte   
                    byte[] dataBytes;	
                    dataBytes = macData.getBytes("UTF-8");

                    System.out.println("Username + Counter byte[] : " + macData);

                    SecretKey secret = new SecretKeySpec(sessionKey, "HMACSHA256");
                    mac.init(secret);
                    doFinal = mac.doFinal(dataBytes);
                    //Convert bytes to hex
                    hexB = new Hex().encode(doFinal);
	        
			str = new String(hexB, "UTF-8");
		
		} 
		catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} 
		catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} 
		catch (InvalidKeyException e) {
			e.printStackTrace();
		}
		
        System.out.println("Main String HEX : " + str);   
        System.out.println("Main HEX value : " + hexB);	
        System.out.println("Main Base64 : " + new String(Base64.encodeBase64(doFinal)));                           
        System.out.println("Final Token : " + Integer.toString(counterValue) + "-" + new String(Base64.encodeBase64(doFinal))); 
        // return USERNAME + Counter + new String(Base64.encodeBase64(doFinal)	
    }
    
    private int createCounter(){
		Date date = new Date();
		int counterValue =  (int) (date.getTime()/(long)60000);
		return counterValue;
	}
    //22656234-B8aFzpacnIo+jgi6CY8PMwTiJLwNaY9VH331lRrwE0I=
    //
    public String getTime(){
        Date dateOne = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddkkmm");
        String time = sdf.format(dateOne);
        return time;
    }
    
//    public int getCounter(){
//      BufferedReader br = null;
//      StringBuilder sBuilder = new StringBuilder();
//      BufferedWriter bwriter = null;
//      int ctr;
//      try{
//          String sCurrentLine;
//          
//          br = new BufferedReader(new FileReader("C:\\DEV\\Sprint6\\ctr.txt"));
//         
//          while ((sCurrentLine = br.readLine()) != null) {
//                    System.out.println("readCounter() : " + sCurrentLine);
//                    sBuilder.append(sCurrentLine);
//                    }
//          br.close();
//          ctr = Integer.parseInt(sBuilder.toString());
//          System.out.println("Counter ===== " + ctr);
//          bwriter = new BufferedWriter(new FileWriter("C:\\DEV\\Sprint6\\ctr.txt"));
//          ctr++;
//          bwriter.write(Integer.toString(ctr));
//          bwriter.close();
//      }catch (IOException e) {
//                e.printStackTrace();
//      }finally {
//            try {
//                if (br != null)br.close();
//                } 
//                catch (IOException ex) {
//                    ex.printStackTrace();
//                }
//            }
//      ctr = Integer.parseInt(sBuilder.toString());
//      return ctr;
//    }
    
    public byte[] getSessionKey(final int value) throws NoSuchAlgorithmException, UnsupportedEncodingException, NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException{
        //Create time
        
        String time = this.getTime();
        //String time = "201212061121";
        //Pattern : 000011223344
        //String time = "201212041611";   //Delete this  
        System.out.println("Time : " + time);
        //Convert Time to byte
            //byte[] timeBytes = time.getBytes("UTF-8");
        int chunkSize = 2;
        int stringLength = time.length();
        byte[] timeBytes2 = new byte[(stringLength/chunkSize)];
        
        //Split the string into chunks of 2
        for(int i = 0, j = 0; i < stringLength; i+=chunkSize, j++){
             if (i + chunkSize > stringLength) 
                 chunkSize = stringLength  - i;
             System.out.println(time.substring(i, i+2));
             timeBytes2[j] = Byte.valueOf(time.substring(i, i+2));
        }       
        
        Date dt = new Date();
        System.out.println(" 1 Minute chunk " + dt.getTime()/(long)60000);
        //Create Counter  11289572-QPasR4+WYAPdrKmf/frMdACqlFcEjUlN0yhdw7IP0/A=
        
        byte[] counterBytes = HMacTest.toByteArray(value);
        
        //Create byte[] for SessionKey
        byte[] sessionKey = new byte[10];
        //Copy everything into 1 byte array sessionKey[]
        ByteBuffer BB = ByteBuffer.wrap(sessionKey);
        BB.put(timeBytes2);
        BB.put(counterBytes);
        
        //Print out the sessionKey byte array
        System.out.print("getSessionKey byte[] : ");
        
        for(int i = 0 ; i < sessionKey.length; i++){
            System.out.print(" "+sessionKey[i]);
        }
        
        System.out.print("\n");    
        
        String s = new String(sessionKey);
        System.out.println("getSessionKey String: " + s);
       
        //read in MasterKey
        String masterKey = this.readMasterKey();
        //Convert masterKey to byte[]
        byte[] mKey = masterKey.getBytes("UTF-8");
        //Perform hMac
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKey secret = new SecretKeySpec(mKey, "HMACSHA256");
        mac.init(secret);
        byte[] sessionKeyFinal = mac.doFinal(sessionKey);
        System.out.println("sessionKeyFinal : " + sessionKeyFinal);
        // return with the sessionKey
        byte[] hexB = new Hex().encode(sessionKeyFinal);
       
        
      
        System.out.println("getSessionKey HEX value : " + hexB);
	String str =  new String(hexB, "UTF-8");
        System.out.println("getSessionKey String HEX : " + str);
        
        System.out.println("getSessionKey Base64 " + new String(Base64.encodeBase64(sessionKeyFinal)));                       
      
        String s2 = new String(sessionKeyFinal);
        System.out.println("getSessionKey String: " + s2); 
        System.out.println("Length: " + sessionKeyFinal.length); 
        
        return sessionKeyFinal;
    }
    
//     public String readCounter(){
//        BufferedReader br = null;
//        BufferedWriter bwriter;
//        StringBuilder sBuilder = new StringBuilder();
//        String Counter;
//        try {
//            String sCurrentLine;
//
//            br = new BufferedReader(new FileReader("C:\\DEV\\Sprint6\\Counter.txt"));
//            bwriter = new BufferedWriter(new FileWriter("C:\\DEV\\Sprint6\\Counter.txt"));
//            while ((sCurrentLine = br.readLine()) != null) {
//                    System.out.println("readCounter() : " + sCurrentLine);
//                    sBuilder.append(sCurrentLine);
//                    int i = Integer.valueOf(sBuilder.toString());
//                    i++;
//                    bwriter.write(i);
//                    }      
//            } 
//            catch (IOException e) {
//                e.printStackTrace();
//            } 
//            finally {
//            try {
//                if (br != null)br.close();
//                } 
//                catch (IOException ex) {
//                    ex.printStackTrace();
//                }
//            }
//            Counter = sBuilder.toString();
//            return Counter;      
//        }
     
    public String readMasterKey(){
        BufferedReader br = null;
        StringBuilder sBuilder = new StringBuilder();
        String mKey;
        try {
            String sCurrentLine;

            br = new BufferedReader(new FileReader("C:\\DEV\\Sprint6\\mKey.txt"));

            while ((sCurrentLine = br.readLine()) != null) {
                    System.out.println("readMasterKey() : " + sCurrentLine);
                    sBuilder.append(sCurrentLine);
                    }      
            } 
            catch (IOException e) {
                e.printStackTrace();
            } 
            finally {
            try {
                if (br != null)br.close();
                } 
                catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
            mKey = sBuilder.toString();
            return mKey;      
        }
    
    public static byte[] toByteArray(int data) {
    return new byte[] {
        (byte)((data >> 24) & 0xff),
        (byte)((data >> 16) & 0xff),
        (byte)((data >> 8) & 0xff),
        (byte)((data >> 0) & 0xff),
        };
    }

}
