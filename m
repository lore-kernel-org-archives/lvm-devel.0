From: Marius Vollmer <marius.vollmer@redhat.com>
Date: Fri, 30 Jan 2015 09:51:44 +0200
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <20150129200344.GO23957@agk-dp.fab.redhat.com>
References: <87r3udicy7.fsf@red.mvo.lan>,
	<20150129200344.GO23957@agk-dp.fab.redhat.com>
Message-ID: <87oapgiu3z.fsf@red.mvo.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> writes:

> Sounds like we forgot to update the library code to use the new method...

I filed a bug for this:

    https://bugzilla.redhat.com/show_bug.cgi?id=1187481

Let us know how we are going to fix this.  If lvm2app is really a lost
cause, we can change storaged to fork lvs etc and parse it's output.


