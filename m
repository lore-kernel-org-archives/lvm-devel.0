From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Oct 2009 11:16:14 +0000
Subject: [PATCH]: Enable snapshots of mirrors
In-Reply-To: <480ED1EC-3EB5-494E-9C75-85AFE6075466@redhat.com>
References: <1256237661.14726.3.camel@hydrogen.msp.redhat.com>
	<20091022194532.GE10165@agk-dp.fab.redhat.com>
	<480ED1EC-3EB5-494E-9C75-85AFE6075466@redhat.com>
Message-ID: <20091026111614.GB25303@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

OK - I've checked this in.

Several 'loose ends' during my review (not all related to this change).

- lvdisplay needs some attention.  It's meant to be the 'user-friendly'
output tool for normal configurations so should spot and tell people 
they have a 'snapshot of a mirror' etc.

- vgsplit -n is not written to handle a stack of LVs.  It could handle
a mirror of a snapshot but not a snapshot of a mirror.  I've reversed
that, but the code needs rewriting to handle a generic stack of LVs.
There is a workaround using alternative syntax (without -n) so splits 
can still be done.  It's not a very big job to fix this, but I've
opened bz 530959.

- The single-character 'type' at the front of the attributes in 'lvs'
is now under impossible strain.  I've changed it to show 'o'
rather than 'm' in the current case, because you can normally tell it's a
mirror from other columns in the output.  In some cases there could be
2, 3 or more pieces of information to display there, so we're either
going to need more attributes appending, or to introduce one or more new
fields.

Alasdair


