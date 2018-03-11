# notice
*if u use it, maybe debugging madness of C api client library*


### install dependency soft
for ops sudo user && need gcc 4.8+ && lua 5.1+ && zookeeper c api(3.4.10)
```
mkdir -p ~/opt

cd  ~/opt
wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
tar zxvf zookeeper-3.4.10.tar.gz
cd zookeeper-3.4.10/src/c 
./configure && make
sudo make install

cd ~/opt
wget http://www.lua.org/ftp/lua-5.1.5.tar.gz
tar zxvf lua-5.1.5.tar.gz
cd lua-5.1.5 && make linux/macosx test (notice: need readline-devel.x86_64)
sudo make install
```

### install lua-zkclient
```
git clone https://github.com/weegate/lua-zkclient.git lua-zkclient
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
make 
ldd zklua.so (otool -L zklua.so for MacOS)
sudo make install
```




