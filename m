From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Aug 2013 12:42:32 +0200
Subject: LVM2 test script failed, is it a read_ahead bug?
In-Reply-To: <521C78A5.5000108@suse.com>
References: <521C78A5.5000108@suse.com>
Message-ID: <521C8298.9060709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.8.2013 12:00, Dongmao Zhang napsal(a):
> Dear mail-list,
>      I met this in running the test case for lvm:
> sh shell/read-ahead.sh FAILED:
>

>
> -               if (current_read_ahead >= read_ahead) {
> +               if (current_read_ahead <= read_ahead) {
>                          log_debug_activation("%s: retaining kernel read
> ahead of %" PRIu32
>                                    " (requested %" PRIu32 ")",
>                                    dev_name, current_read_ahead, read_ahead);
>
> If I am wrong, please correct me:)
>


Basic rules for 'auto'mated read_ahead setting is simple: never set smaller 
value then the one which has been already set by kernel when device has been 
initialized.

If you need any specific more 'clever' value - simply use direct value for
lvcreate/lvchange --readahead.

There is no thing like 'minimal' RA estimation in lvm2.

It's quite tricky to estimate the ideal RA for devices and it mostly depends
on the type of use.

Zdenek


