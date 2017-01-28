/**
 * This is a simple implementation in prediction using linear regression.
 * This implementation focus on predicting how many days electricity quota
 * can be used until it's drop out.
 * 
 * @author Ilham Kusuma
 * */
import java.util.ArrayList;


public class QuotaPrediction  {
		
	/**
	 * This method return how many days left until the quota left under 50 kWh.
	 * This method using linear regression to make the prediction. linear 
	 * regression is used under assumption that the data is relative simple
	 * and can be accurately predict in linear formula.
	 *   
	 * @param arr is array of quota
	 * @return number of days until the quota drop out
	 * */
	public static int predict(double [] arr){
        double sumx = 0.0, sumy = 0.0, sumx2 = 0.0;
        double[] x = new double[arr.length];
        double[] y = arr;
		for(int i = 0; i < arr.length; i++)   {
            x[i] = i;
            sumx  += x[i];
            sumx2 += x[i] * x[i];
            sumy  += y[i];
		}

        double xbar = sumx / arr.length;
        double ybar = sumy / arr.length;

        // second pass: compute summary statistics
        double xxbar = 0.0, xybar = 0.0;
        for (int i = 0; i < arr.length; i++) {
            xxbar += (x[i] - xbar) * (x[i] - xbar);
            xybar += (x[i] - xbar) * (y[i] - ybar);
        }
        double beta1 = xybar / xxbar;
        double beta0 = ybar - beta1 * xbar;
        
        double hasil = (50 - beta0)/beta1;
        double f = ((int)hasil)*beta1+beta0;
        System.out.println("kuota listrik anda akan habis dalam "+(ceil(hasil)+1-arr.length)+" hari");
        System.out.println("dalam "+(floor(hasil)+1-arr.length)+" hari sisa kuota anda akan tersisa "+f);
        System.out.println("model : y = "+(beta1)+"x + "+beta0);

        return (int)hasil;
	}
	
	private static int floor(double v){
		return (int)v;
	}
	
	private static int ceil(double v){
		return (int)v+1;
	}
	/**
	 * This method return an array of Quota. This method specially created
	 * to remove unused data from raw data.
	 * @param list is a raw data with format "date;quota left"
	 * @return array of quota that had been cleansed
	 * */
	public static double[] getQuotaData(String [] list){
	    ArrayList<String> listSKPilihan = new ArrayList<String>();
	    listSKPilihan.add(list[list.length-1].split(";")[1]);
	    int tempSisaKuotaBuntut = Integer.parseInt(list[list.length-1].split(";")[1]);
	    boolean stop = false;
	    for(int i = list.length-2; i >= 0 && !stop; i--){
	        int tempSisaKuota = Integer.parseInt(list[i].split(";")[1]);
	        if(tempSisaKuota>tempSisaKuotaBuntut){
	            listSKPilihan.add(0,list[i].split(";")[1]);
	            tempSisaKuotaBuntut = tempSisaKuota;
	        } else {
	            stop = true;
	        }
	    }
	    double [] listdouble = new double[listSKPilihan.size()];
	    for(int i = 0; i < listdouble.length; i++){
	        listdouble[i] = Double.parseDouble(listSKPilihan.get(i));
	    }
	    return listdouble;
	}
	
	public static void main(String [] args){
		String [] rawData = {
				"29/12/2014;90",
				"30/12/2014;53",
				"31/12/2014;3",
				"1/1/2015;3",
				"2/1/2015;500",
				"3/1/2015;470",
				"4/1/2015;430",
				"5/1/2015;400",
				"6/1/2015;365",
				"7/1/2015;330"};
		double [] listOfQuotaPerDay = getQuotaData(rawData);

		predict(listOfQuotaPerDay);
	}
}
