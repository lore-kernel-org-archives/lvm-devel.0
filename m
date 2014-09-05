From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Thu, 4 Sep 2014 23:32:18 -0700 (PDT)
Subject: Welcome to the "lvm-devel" mailing list
In-Reply-To: <mailman.0.1409897391.21455.lvm-devel@redhat.com>
References: <mailman.0.1409897391.21455.lvm-devel@redhat.com>
Message-ID: <alpine.DEB.2.00.1409042320360.21427@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Good day all,

Today I was playing with lvmthin and did a metadata dump and restore with 
thin_dump.  I was low on space so I `thin_dump --repair`ed through gzip 
into restore.xml.gz, and hoped to

   zcat restore.xml.gz | thin_restore -i /proc/self/fd/0 -o /dev/mapper/pool-pool_tmeta

but it says /proc/self/fd/0 is "Not a regular file" ... which of course it isn't.

Watching lsof -o on thin_restore indicates a linear progression through 
the input (looks like a simple ifstream), so technically, I believe it 
could support this.


persistent-data/file_utils.cc:~57:
   persistent_data::check_file_exists(string const &file) does the 
"Regular file check."

It looks that persistent_data::check_file_exists is used in cache_restore 
and xml_parser::parse, both appear to read linearly without arbitrary seek 
so it might be safe to relax or modify that check.

Of course blindly skipping the "Not a regular file" bit might bypass 
possible problems if used to sanitize file existence elsewhere in the 
code---but at least for XML restores it would have saved me some time.

Please comment on whether or not this is a good idea and how it would best 
be implemented.  This is my first runthrough on the userspace thinp tools, 
so your input expertise is appreciated!

-Eric

--
Eric Wheeler
eWheeler Inc
www.ewheeler.net


