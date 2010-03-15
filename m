From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 15 Mar 2010 15:00:51 -0400 (EDT)
Subject: lv-shared
Message-ID: <Pine.LNX.4.64.1003151453350.4733@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Why did you hide the "lv-shared" volume? With this hidden, the size and 
percentage can't be seen.

Also, your changes to 2.02.62 broke shared store resizing.
lvresize -L 132M vgs/lv-shared no longer works

Mikulas


