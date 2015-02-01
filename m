From: Oliver Rath <rath@mglug.de>
Date: Sun, 01 Feb 2015 11:35:08 +0100
Subject: lvm2 compile error with python-3.x on gentoo
Message-ID: <54CE015C.5080609@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

compiling the actual code-base of lvm2 gets an error on gentoo with a
newer python-release than 3.2:

Ive started with python-3.2:

./configure       --with-thin=internal      
--with-replicators=internal       --enable-udev_sync      
--enable-udev_rules       --enable-python-bindings      
--enable-applib       --enable-cmdlib       --with-cache=internal      
--enable-lvmetad --enable-dmeventd

[..]

then the build is broken:

[..]
liblvm_python.c: In function '_liblvm_lvm_lv_get_tags':
/usr/include/python3.2/tupleobject.h:62:73: warning: assignment makes
pointer from integer without a cast [enabled by default]
 #define PyTuple_SET_ITEM(op, i, v) (((PyTupleObject *)(op))->ob_item[i]
= v)
                                                                         ^
liblvm_python.c:1493:3: note: in expansion of macro 'PyTuple_SET_ITEM'
   PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
   ^
liblvm_python.c: In function 'initlvm':
liblvm_python.c:2010:10: warning: assignment makes pointer from integer
without a cast [enabled by default]
  if (!(m = Py_InitModule3("lvm", _Liblvm_methods, "Liblvm module")))
          ^
error: command 'i686-pc-linux-gnu-gcc' failed with exit status 1
make[1]: *** [.liblvm_built] Error 1
rm liblvm_python.c
make[1]: Leaving directory `/mnt/lvm2/python'
make: *** [python] Error 2

Now I change to python-2.7:
heimserver lvm2 # eselect python list
Available Python interpreters:
  [1]   python2.6
  [2]   python2.7
  [3]   python3.2 *
  [4]   python3.2
  [5]   python3.4
heimserver lvm2 # eselect python set 2

Now all is fine:
[..]
running build_ext
building 'lvm' extension
creating build/temp.linux-i686-2.7
i686-pc-linux-gnu-gcc -pthread -fPIC -I../include
-I/usr/include/python2.7 -c liblvm_python.c -o
build/temp.linux-i686-2.7/liblvm_python.o
creating build/lib.linux-i686-2.7
i686-pc-linux-gnu-gcc -pthread -shared -Wl,-O1 -Wl,--as-needed -L.
build/temp.linux-i686-2.7/liblvm_python.o -L../liblvm -L/usr/lib
-llvm2app -lpython2.7 -o build/lib.linux-i686-2.7/lvm.so
touch .liblvm_built
rm liblvm_python.c
make[1]: Leaving directory `/mnt/lvm2/python'

Regards,
Oliver


