From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 29 Jan 2015 20:03:44 +0000
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <87r3udicy7.fsf@red.mvo.lan>
References: <87r3udicy7.fsf@red.mvo.lan>
Message-ID: <20150129200344.GO23957@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jan 29, 2015 at 09:50:08PM +0200, Marius Vollmer wrote:
> at one moment lvm_lv_get_property returned a valid and useful "lv_attr"
> property, and then suddenly it returns values with "is_valid == 0".
 
The way some of the properties are gathered got changed.

Sounds like we forgot to update the library code to use the new method...

Alasdair


