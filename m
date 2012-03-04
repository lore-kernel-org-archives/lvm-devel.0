From: ben <benscott@nwlink.com>
Date: Sat, 03 Mar 2012 21:06:15 -0800
Subject: A bug in liblvm2app: lvm_pv_get_property()
Message-ID: <1443975.PGRcsSfSxn@laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm version: 2.02.88

When calling the function:
value = lvm_pv_get_property(lvm_pv, "pv_tags")

The returned value doesn't always get terminated. The attribute characters at 
the start are correct but the string continues with garbage. The value is 
checked for validity with  value.is_valid first.

Thank you.



