From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 4 Jul 2012 18:41:48 +0100
Subject: lvm2-api usage in GlusterFS
In-Reply-To: <87txxnqvok.fsf@in.ibm.com>
References: <87txxnqvok.fsf@in.ibm.com>
Message-ID: <20120704174148.GJ22022@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 04, 2012 at 11:02:11PM +0530, M.Mohan Kumar wrote:
> When open request comes in the gluster mount path, server side code
> opens the intended LV by using this logic: /dev/<vg-name>/<lv-name>.
> This path is actually a symbolic link to /dev/dm-<x>. Is my assumption
> about having this /dev/<vg-name>/<lv-name> is it right? Will it
> always work?
 
That is the right link to use as it depends only on the VG name and the LV
name.

The /dev/mapper and /dev/dm-N entries might change.

Alasdair


