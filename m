From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Sat, 19 Oct 2019 00:29:18 +0000 (UTC)
Subject: transaction_manager::new_block() couldn't allocate new block
Message-ID: <alpine.LRH.2.11.1910182133220.13914@mx.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello all, 

We are attempting to repair a thin meta volume and get the following 
error after it runs for a while:

~]# thin_repair -V
0.8.5

~]# thin_repair -i /dev/mapper/data-data--pool_tmeta -o /dev/data/tmeta-dest 
truncating metadata device to 4161600 4k blocks
terminate called after throwing an instance of 'std::runtime_error'
  what():  transaction_manager::new_block() couldn't allocate new block
Aborted (core dumped)

How I can troubleshoot this further?

I'm happy to try patches against thin_repair if you would like.  I'm also 
trying thin_dump/thin_restore, so we will see how that goes---but I 
thought you might want to know in case there is a bug in thin_repair that 
could be fixed while I have the metadata in this state.

--
Eric Wheeler


