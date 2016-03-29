rm -r brf_results* out.log* om-k.dat* time.txt rho.dat result.dat
cp nrk.ini_0.1 nrk.ini
#nohup /usr/bin/time -p -o time.txt NRK_brf_no_AD.exe > out.log &  2>&1
echo "****** 0.1"
NRK_brf_no_AD.exe
mv brf_results brf_results_0.1
mv om-k.dat om-k.dat_0.1
rm -r out.log om-k.dat time.txt rho.dat result.dat

echo "****** 0.6"
cp nrk.ini_0.6 nrk.ini
NRK_brf_no_AD.exe
mv brf_results brf_results_0.6
mv om-k.dat om-k.dat_0.6
rm -r out.log om-k.dat time.txt rho.dat result.dat

cat om-k.dat_0.1 > om-k.dat
cat om-k.dat_0.6 | sort -n -k2 > om-k.dat_0.6_sorted
cat om-k.dat_0.6_sorted >> om-k.dat

mkdir ./brf_results
mv brf_results_0.6/* ./brf_results/
mv brf_results_0.1/* ./brf_results/
rm -r om-k.dat_* brf_results_0.6 brf_results_0.1
