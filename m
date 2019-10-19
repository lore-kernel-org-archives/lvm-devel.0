From: Nikhil Kshirsagar <nkshirsa@redhat.com>
Date: Sat, 19 Oct 2019 08:17:29 +0530
Subject: transaction_manager::new_block() couldn't allocate new block
In-Reply-To: <alpine.LRH.2.11.1910182133220.13914@mx.ewheeler.net>
References: <alpine.LRH.2.11.1910182133220.13914@mx.ewheeler.net>
Message-ID: <CAMNNMLEhvN5Ow08=hDWePoQ3xeKdDVuEF+cWUtRu+m7589+kkA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I recollect running into this one a few months ago on 0.8.5 , and i think
Joe fixed this in 0.8.5-1 , please try with the latest version of the pdata
tools.

On Sat, 19 Oct, 2019, 6:08 AM Eric Wheeler, <lvm-devel@lists.ewheeler.net>
wrote:

> Hello all,
>
> We are attempting to repair a thin meta volume and get the following
> error after it runs for a while:
>
> ~]# thin_repair -V
> 0.8.5
>
> ~]# thin_repair -i /dev/mapper/data-data--pool_tmeta -o
> /dev/data/tmeta-dest
> truncating metadata device to 4161600 4k blocks
> terminate called after throwing an instance of 'std::runtime_error'
>   what():  transaction_manager::new_block() couldn't allocate new block
> Aborted (core dumped)
>
> How I can troubleshoot this further?
>
> I'm happy to try patches against thin_repair if you would like.  I'm also
> trying thin_dump/thin_restore, so we will see how that goes---but I
> thought you might want to know in case there is a bug in thin_repair that
> could be fixed while I have the metadata in this state.
>
> --
> Eric Wheeler
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20191019/d7087621/attachment.htm>
