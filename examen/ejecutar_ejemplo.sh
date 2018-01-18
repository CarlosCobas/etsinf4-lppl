make
for i in $(ls tmp/ejem.c); do
	./cmc -v "$i";
	bin/mvm "$i"3d;
done
