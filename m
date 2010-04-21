From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 21 Apr 2010 15:38:05 -0400
Subject: Allowing an actively merging snapshot to be removed?
In-Reply-To: <20100421063504.GA10083@redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
	<20100419232509.GG4828@agk-dp.fab.redhat.com>
	<20100421063504.GA10083@redhat.com>
Message-ID: <20100421193804.GA28717@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 21 2010 at  2:35am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

>    when a merge is active the merging
>    snapshot LV is accessible (by user with lvremove); so removing the
>    merging snapshot is currently allowed (stops merge, deletes
>    snapshot); should it be allowed?

Hi Mikulas,

What are your thoughts on this corner case?

thanks,
Mike


