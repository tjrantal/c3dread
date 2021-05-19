
package org.j3d.loaders.c3d;


/**
 * The representation of most of the event parameter of a C3D file. 
 * Vicon c3d exports use the event parameter as opposed to using
 * the header event <p>
 * 
 * The definition of the file format can be found at:
 * <a href="http://www.c3d.org">http://www.c3d.org/</a>
 *
 * @author  Timo Rantalainen
 * @version $Revision: 0.1 $
 */
public class C3DEventData
{
   public String[] labels;
   public String[] descriptions;
   public String[] contexts;
   public double[] times;
  
  public C3DEventData(String[] labels,String[] descriptions,String[] contexts,double[] times){
	  this.labels = labels;
	  this.descriptions = descriptions;
	  this.contexts = contexts;
	  this.times = times;
  }
}

