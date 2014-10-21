From: lilofile <lilofile@aliyun.com>
Date: Tue, 21 Oct 2014 18:24:55 +0800
Subject: device mapper library update
In-Reply-To: <20141007001622.823F66036F@fedorahosted.org>
References: 20141007001622.823F66036F@fedorahosted.org
Message-ID: <f277c43b-8d1a-43f2-838c-b2fb33bcc67d@aliyun.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

when I download LVM2.2.02.104.tgz source code, tar xvf
./configure;make;make install

then use lvcreate --version, the result display
[root at localhost ~]# lvcreate  --version
  LVM version:     2.02.104(2) (2013-11-13)
  Library version: 1.02.79-RHEL6 (2013-10-23)
  Driver version:  4.24.0
[root at localhost ~]#

why the Library version is not updated?
 when I see the source code ,
include/configure.h:#define DM_LIB_VERSION "1.02.83 (2013-11-13)"
lib/misc/configure.h:#define DM_LIB_VERSION "1.02.83 (2013-11-13)"

the version display is 1.02.83? 


