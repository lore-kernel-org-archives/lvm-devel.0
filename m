From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 6 Apr 2010 14:39:24 +0100
Subject: [PATCH 5/5] Add pv->vg to solidify link between a pv and a vg.
In-Reply-To: <1270497099-13259-6-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-3-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-4-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-5-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-6-git-send-email-dwysocha@redhat.com>
Message-ID: <20100406133924.GF30760@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm not convinced this patch catches everything yet.

E.g. vg_remove_check has a:
                dm_list_del(&pvl->list);
and I don't spot the matching pv->vg change.
If it's there, it's well-hidden.

Every place in the code where vg->pvs changes should have a corresponding
pv->vg change next to it.

Alasdair


