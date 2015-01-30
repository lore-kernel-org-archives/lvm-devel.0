From: Marius Vollmer <marius.vollmer@redhat.com>
Date: Fri, 30 Jan 2015 11:32:36 +0200
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <54CB4B79.8000005@redhat.com>
References: <87r3udicy7.fsf@red.mvo.lan>, <87oapgiu3z.fsf@red.mvo.lan>,
	<54CB4B79.8000005@redhat.com>
Message-ID: <87mw50ipfv.fsf@red.mvo.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:

> Unfortunately, this was a regression introduced in LVM2 v115. It should
> be fixed now (https://bugzilla.redhat.com/show_bug.cgi?id=1187481#c2).

Thanks!  (I think there is more to do, unfortunately, see the bug.)

> I wouldn't say lvm2app is unusable, it's just not as maintained and
> refreshed as direct LVM tools. [...]

Do you know of any users besides storaged?

We should cooperate and make somehow sure that the storaged and Cockpit
tests run for each LVM2 update...


