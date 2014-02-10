From: Chiyohiko Morita <morita@valinux.co.jp>
Date: Mon, 10 Feb 2014 20:34:30 +0900
Subject: VG archive files won't be removed after a long run.
Message-ID: <20140210203429.752A.DDAE3F33@valinux.co.jp>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


(I'm not on this list; please Cc me)

When the VG archive file is created more than 100,000 times, 
if there don't exist files with indices from "00000" to "10000",
the file name always because vg_name_100000-random_numbers.vg.
The index number part of the names is always "100000".

I think that there is a problem with the _insert_archive_file() function.
The last line of the _insert_archive_file() function is to add a table 
at the head of the archives list. (See line indicated by (*))
I think in this case, and you should add the table at the tail of the list.

The related source code is shown below.

==============================================================================
lvm2-2_02_104/lib/format_text/archive.c
------------------------------------------------------------------------------
static void _insert_archive_file(struct dm_list *head, struct archive_file *b)
{
        struct archive_file *bf = NULL;

        if (dm_list_empty(head)) {
                dm_list_add(head, &b->list);
                return;
        }

        /* index reduces through list */
        dm_list_iterate_items(bf, head) {
                if (b->index > bf->index) {
                        dm_list_add(&bf->list, &b->list);
                        return;
                }
        }

        dm_list_add_h(&bf->list, &b->list);	(*)
}


Additional info:

<example: File index number 00000-10000 does not exist.>
[archive]# ls -al
total 406320
drwxr-xr-x. 2 root root 6402048 Feb 10  2014 .
drwxr-xr-x. 7 root root    4096 Feb 10  2014 ..
-rw-------. 1 root root    2378  1? 31 18:24 2014 test-vg_100000-1204670439.vg	(**)
-rw-------. 1 root root    1773  1? 31 18:10 2014 test-vg_100000-1241353072.vg	(**)
-rw-------. 1 root root    2378  1? 31 17:59 2014 test-vg_100000-1369206884.vg	(**)
-rw-------. 1 root root    2378  1? 31 18:21 2014 test-vg_100000-1740312384.vg	(**)
-rw-------. 1 root root    1773  1? 31 18:31 2014 test-vg_100000-1798506701.vg	(**)
-rw-------. 1 root root    2378  1? 31 17:50 2014 test-vg_100000-2045350629.vg	(**)
-rw-------. 1 root root    2086  1? 29 15:09 2014 test-vg_10001-444418726.vg
-rw-------. 1 root root    2705  1? 29 15:09 2014 test-vg_10002-991152144.vg
-rw-------. 1 root root    3322  1? 29 15:09 2014 test-vg_10003-1382812875.vg
-rw-------. 1 root root    3925  1? 29 15:09 2014 test-vg_10004-1229258138.vg
	:
-rw-------. 1 root root    3322  1? 31 02:14 2014 test-vg_99997-1786673524.vg
-rw-------. 1 root root    3925  1? 31 02:14 2014 test-vg_99998-1284671590.vg
-rw-------. 1 root root    3306  1? 31 02:14 2014 test-vg_99999-1949909947.vg

(**):Index numbers are the same.

<example: File index number 00000-10000 exist.>
[archive]# ls -al
?? 366668
drwxr-xr-x. 2 root root 6402048  2? 10 11:55 2014 .
drwxr-xr-x. 7 root root    4096  2? 10 11:43 2014 ..
-rw-------. 1 root root    1109  1? 29 11:59 2014 test-vg_00000-2082297108.vg
-rw-------. 1 root root    1442  1? 29 12:00 2014 test-vg_00001-190015709.vg
-rw-------. 1 root root    1771  1? 29 12:01 2014 test-vg_00002-1842787566.vg
	 :
-rw-------. 1 root root    3925  1? 29 15:09 2014 test-vg_09998-916990031.vg
-rw-------. 1 root root    3306  1? 29 15:09 2014 test-vg_09999-800050091.vg
-rw-------. 1 root root    2685  1? 29 15:09 2014 test-vg_10000-746926820.vg
-rw-------. 1 root root    2685  1? 31 02:14 2014 test-vg_100000-528314802.vg
-rw-------. 1 root root    2086  1? 31 02:14 2014 test-vg_100001-1539419450.vg
	:
-rw-------. 1 root root    3322  1? 31 02:15 2014 test-vg_100009-168721966.vg
-rw-------. 1 root root    2086  1? 29 15:09 2014 test-vg_10001-444418726.vg
-rw-------. 1 root root    3925  1? 31 02:15 2014 test-vg_100010-1968226420.vg
-rw-------. 1 root root    2086  1? 31 02:14 2014 test-vg_100001-1539419450.vg
	:
-rw-------. 1 root root    2086  1? 31 02:15 2014 test-vg_100019-589867197.vg
-rw-------. 1 root root    2705  1? 29 15:09 2014 test-vg_10002-991152144.vg
-rw-------. 1 root root    2705  1? 31 02:15 2014 test-vg_100020-300714866.vg
-rw-------. 1 root root    3322  1? 31 02:15 2014 test-vg_100021-333183948.vg
	:
-rw-------. 1 root root    3306  1? 31 02:15 2014 test-vg_100029-249595924.vg
-rw-------. 1 root root    3322  1? 29 15:09 2014 test-vg_10003-1382812875.vg
-rw-------. 1 root root    2685  1? 31 02:15 2014 test-vg_100030-1220134385.vg
-rw-------. 1 root root    2086  1? 31 02:15 2014 test-vg_100031-981943972.vg
	:
-rw-------. 1 root root    3322  1? 31 02:16 2014 test-vg_100039-1249509839.vg
-rw-------. 1 root root    3925  1? 29 15:09 2014 test-vg_10004-1229258138.vg
-rw-------. 1 root root    3925  1? 31 02:16 2014 test-vg_100040-1288607163.vg
	:
-rw-------. 1 root root    2086  1? 31 02:17 2014 test-vg_100097-450415415.vg
-rw-------. 1 root root    2705  1? 31 02:17 2014 test-vg_100098-1044414870.vg
-rw-------. 1 root root    3322  1? 31 02:17 2014 test-vg_100099-1167588496.vg
-rw-------. 1 root root    3925  1? 29 15:09 2014 test-vg_10010-128770730.vg
-rw-------. 1 root root    3306  1? 29 15:09 2014 test-vg_10011-1575005460.vg
-rw-------. 1 root root    2685  1? 29 15:09 2014 test-vg_10012-1276134968.vg
-rw-------. 1 root root    2086  1? 29 15:09 2014 test-vg_10013-2102715722.vg
-rw-------. 1 root root    2705  1? 29 15:09 2014 test-vg_10014-2041113299.vg
-rw-------. 1 root root    3322  1? 29 15:09 2014 test-vg_10015-1772090647.vg
	:
-rw-------. 1 root root    3322  1? 31 02:14 2014 test-vg_99997-1786673524.vg
-rw-------. 1 root root    3925  1? 31 02:14 2014 test-vg_99998-1284671590.vg
-rw-------. 1 root root    3306  1? 31 02:14 2014 test-vg_99999-1949909947.vg

- - - - - - - - - - - - - - - - - - - -

Thanks,

--
Chiyohiko Morita <morita valinux co jp>


