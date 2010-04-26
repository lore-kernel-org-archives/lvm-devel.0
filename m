From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 14:34:28 +0100
Subject: [PATCH 02/22] API change for args of process_each_lv_in_vg()
In-Reply-To: <a8d5213653f20de8cc203ef59651c9ea912dd26b.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<a8d5213653f20de8cc203ef59651c9ea912dd26b.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426133428.GL23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:30PM +0200, Zdenek Kabelac wrote:
> Patch adds failed_lvs to the list of parameters for process_each_lv_in_vg().
> If the list is not NULL it will be filled with lv_names of failing LVs
> during function execution.
> Application could later reiterate only on failed LVs.
 
OK.

Alasdair


