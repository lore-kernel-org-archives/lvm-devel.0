From: Gk Gk <ygk.kmr@gmail.com>
Date: Mon, 30 Jan 2023 18:07:03 +0530
Subject: Need assistance
Message-ID: <CAJreVFygf+13+2PM5wYkDQAxyzVDd=nCiP=P4nhi18bUY=W4mQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi All,


I have two nvme disks with different sector sizes of 512 and 4096
respectively. When I try
to use them in creating a volume group, it is complaining to set the
'allow_mixed_block_sizes' option in lvm.conf file. But I read elsewhere
that doing this would corrupt data.

Can anyone explain to me under what specific case/cases  will I loose data
if I allow mixed blocked sizes ?


Thanks
Kumar
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230130/b708f8d0/attachment.htm>
