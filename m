From: Liuhua Wang <lwang@suse.com>
Date: Wed, 22 Apr 2015 21:34:54 -0600
Subject: How to judge a vg is empty
Message-ID: <5538D8DE020000A000010BE1@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

I'd like to remove the limit of LVM RA that does not support an vg with no lvs,
because it is not convenient while configuring the resource especially through 
wizard like hawk. The wizard has to be split into two parts.

First I would like to use this command. 
       `vgdisplay vg_name | awk '/Cur LV/{print $3}'  `
  If the Cur LV  is 0 then look the vg as empty.

 But as to ResourceAgent upstream says, it is not recommended to use any lvm commands
 in RA monitor/status function because of the execute time issue.
 
Then I suppose I can check the backup file. 
        `grep "logical_volumes" /etc/lvm/backup/vg_name`
  If string "logical_volumes" is found in backup/vg_name it means this vg is not empty.

I want to know whether this is a reliable way to announce a vg empty or is there a better way?
Thanks!

Best regards
     Liuhua




