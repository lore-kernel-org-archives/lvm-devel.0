From: Marius Vollmer <marius.vollmer@redhat.com>
Date: Thu, 29 Jan 2015 21:50:08 +0200
Subject: "lv_attr" disappeared from lvm_lv_get_property?
Message-ID: <87r3udicy7.fsf@red.mvo.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

at one moment lvm_lv_get_property returned a valid and useful "lv_attr"
property, and then suddenly it returns values with "is_valid == 0".

I think it works with lvm2-2.02.111-1.fc21.x86_64 and am sure it fails
with lvm2-2.02.115-1.fc21.x86_64.

Furthermore, lvm_lv_get_attr, which might be the right function to use
in the first place, returns a incomplete value like "twi-XXtz--" where
the 'active' and 'open' fields are set to "unknown".

The lvs command still displays the correct values with "lvs -o lv_attr".

What in the name of holy backwards compatibility is going on here?


