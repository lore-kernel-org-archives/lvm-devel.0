From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 26 Apr 2010 09:46:08 -0400
Subject: [PATCH 02/22] API change for args of process_each_lv_in_vg()
In-Reply-To: <a8d5213653f20de8cc203ef59651c9ea912dd26b.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<a8d5213653f20de8cc203ef59651c9ea912dd26b.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426134608.GA17144@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12 2010 at 11:21am -0400,
Zdenek Kabelac <zkabelac@redhat.com> wrote:

> Patch adds failed_lvs to the list of parameters for process_each_lv_in_vg().
> If the list is not NULL it will be filled with lv_names of failing LVs
> during function execution.
> 
> Application could later reiterate only on failed LVs.

Alasdair's recent comment highlighted this change.  Minor nit, maybe
rename the 'failed_lvs' to 'failed_lvnames'?

Mike


