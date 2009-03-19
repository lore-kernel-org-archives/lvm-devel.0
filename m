From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 19 Mar 2009 12:40:07 -0400
Subject: [PATCH] remove old backup file after renaming vg
In-Reply-To: <20090319160921.GV3063@agk.fab.redhat.com>
References: <49C26A35.105@redhat.com>
	<20090319160921.GV3063@agk.fab.redhat.com>
Message-ID: <49C27567.7030901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

> On Thu, Mar 19, 2009 at 11:52:21AM -0400, Takahiro Yasui wrote:
>> This patch removes an old backup file after renaming vg
>> by the vgrename command.
>  
> Ack provided that an archive file with identical contents already
> got created.

Thank you for reviewing this patch.

Yes, an archive file with identical contents is created before actual
rename action by vg_rename function. The archive and backup sequence
of vg_rename_path function is

  - archive old_vg
  - rename old_vg to new_vg
  - backup new_vg
  - backup_remove old_vg

Thanks,
Taka


