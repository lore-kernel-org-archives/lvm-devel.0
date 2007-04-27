From: agk@sourceware.org <agk@sourceware.org>
Date: Fri, 27 Apr 2007 20:48:39 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW po/lvm2.po
Message-ID: <20070427204715.20342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-27 21:47:14

Modified files:
	.              : VERSION WHATS_NEW 
	po             : lvm2.po 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.611&r2=1.612
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/lvm2.po.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/VERSION	2007/03/19 21:16:49	1.150
+++ LVM2/VERSION	2007/04/27 20:47:14	1.151
@@ -1 +1 @@
-2.02.25-cvs (2007-03-19)
+2.02.25-cvs (2007-04 27)
--- LVM2/WHATS_NEW	2007/04/27 20:41:49	1.611
+++ LVM2/WHATS_NEW	2007/04/27 20:47:14	1.612
@@ -1,4 +1,4 @@
-Version 2.02.25 -
+Version 2.02.25 - 27th April 2007
 =================================
   Fix get_config_uint64() to read a 64-bit value not a 32-bit one.
   Add -Wformat-security and change one fprintf() to fputs().
--- LVM2/po/lvm2.po	2005/08/04 02:02:37	1.20
+++ LVM2/po/lvm2.po	2007/04/27 20:47:14	1.21
@@ -1,12 +1,14 @@
 # SOME DESCRIPTIVE TITLE.
-# Copyright (C) YEAR Free Software Foundation, Inc.
+# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
+# This file is distributed under the same license as the PACKAGE package.
 # FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
 #
 #, fuzzy
 msgid ""
 msgstr ""
 "Project-Id-Version: PACKAGE VERSION\n"
-"POT-Creation-Date: 2005-08-04 00:07+0100\n"
+"Report-Msgid-Bugs-To: \n"
+"POT-Creation-Date: 2007-04-27 21:46+0100\n"
 "PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
 "Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
 "Language-Team: LANGUAGE <LL@li.org>\n"
@@ -14,719 +16,634 @@
 "Content-Type: text/plain; charset=CHARSET\n"
 "Content-Transfer-Encoding: 8bit\n"
 
-#: activate/activate.c:42
+#: activate/activate.c:44
 msgid "LVM1 proc global snprintf failed"
 msgstr ""
 
-#: activate/activate.c:163
-msgid "Activation enabled. Device-mapper kernel driver will be used."
-msgstr ""
-
-#: activate/activate.c:166
-msgid "Activation disabled. No device-mapper interaction will be attempted."
-msgstr ""
-
-#: activate/activate.c:199
-msgid "Ignoring invalid string in config file activation/volume_list"
-msgstr ""
-
-#: activate/activate.c:205
-msgid "Ignoring empty string in config file activation/volume_list"
-msgstr ""
-
-#: activate/activate.c:214
-msgid "Ignoring empty tag in config file activation/volume_list"
-msgstr ""
-
-#: activate/activate.c:244
-#, c-format
-msgid "lvm_snprintf error from %s/%s"
-msgstr ""
-
-#: activate/activate.c:273
-msgid "Getting driver version"
+#: activate/activate.c:63
+msgid "module string allocation failed"
 msgstr ""
 
-#: activate/activate.c:275 activate/activate.c:304 activate/activate.c:347
-#: activate/activate.c:352 activate/activate.c:394 activate/activate.c:399
-#: activate/activate.c:418 activate/activate.c:426 activate/activate.c:431
-#: activate/activate.c:443 activate/activate.c:455 activate/activate.c:469
-#: activate/activate.c:474 activate/activate.c:486 activate/activate.c:491
-#: activate/activate.c:503 activate/activate.c:508 activate/activate.c:568
-#: activate/activate.c:614 activate/activate.c:659 activate/activate.c:728
-#: activate/activate.c:767 activate/dev_manager.c:179
-#: activate/dev_manager.c:197 activate/dev_manager.c:225
-#: activate/dev_manager.c:234 activate/dev_manager.c:239
-#: activate/dev_manager.c:245 activate/dev_manager.c:286
-#: activate/dev_manager.c:294 activate/dev_manager.c:367
-#: activate/dev_manager.c:375 activate/dev_manager.c:380
-#: activate/dev_manager.c:411 activate/dev_manager.c:467
-#: activate/dev_manager.c:472 activate/dev_manager.c:504
-#: activate/dev_manager.c:525 activate/dev_manager.c:539
-#: activate/dev_manager.c:555 activate/dev_manager.c:615
-#: activate/dev_manager.c:621 activate/dev_manager.c:628
-#: activate/dev_manager.c:657 activate/dev_manager.c:714
-#: activate/dev_manager.c:723 activate/dev_manager.c:766
-#: activate/dev_manager.c:772 activate/dev_manager.c:782
-#: activate/dev_manager.c:821 activate/dev_manager.c:835
-#: activate/dev_manager.c:860 activate/dev_manager.c:900
-#: activate/dev_manager.c:905 activate/dev_manager.c:913
-#: activate/dev_manager.c:936 activate/dev_manager.c:941
-#: activate/dev_manager.c:947 activate/dev_manager.c:952
-#: activate/dev_manager.c:958 activate/dev_manager.c:966
-#: activate/dev_manager.c:983 activate/dev_manager.c:988
-#: activate/dev_manager.c:1003 activate/dev_manager.c:1008
-#: activate/dev_manager.c:1041 activate/dev_manager.c:1051
-#: activate/dev_manager.c:1067 activate/dev_manager.c:1077
-#: activate/dev_manager.c:1099 activate/dev_manager.c:1108
-#: activate/dev_manager.c:1122 activate/dev_manager.c:1130
-#: activate/dev_manager.c:1143 activate/dev_manager.c:1163
-#: activate/dev_manager.c:1168 activate/dev_manager.c:1174
-#: activate/dev_manager.c:1196 activate/dev_manager.c:1216
-#: activate/dev_manager.c:1235 activate/dev_manager.c:1246
-#: activate/dev_manager.c:1261 activate/dev_manager.c:1273
-#: activate/dev_manager.c:1287 activate/dev_manager.c:1300
-#: activate/dev_manager.c:1310 activate/dev_manager.c:1350
-#: activate/dev_manager.c:1361 activate/dev_manager.c:1371
-#: activate/dev_manager.c:1379 activate/dev_manager.c:1386
-#: activate/dev_manager.c:1462 activate/dev_manager.c:1481
-#: activate/dev_manager.c:1503 activate/dev_manager.c:1511
-#: activate/dev_manager.c:1539 activate/dev_manager.c:1544
-#: activate/dev_manager.c:1573 activate/dev_manager.c:1579
-#: activate/dev_manager.c:1600 activate/dev_manager.c:1618
-#: activate/dev_manager.c:1632 activate/dev_manager.c:1642
-#: activate/dev_manager.c:1652 activate/dev_manager.c:1670
-#: activate/dev_manager.c:1693 activate/dev_manager.c:1727
-#: activate/dev_manager.c:1743 activate/dev_manager.c:1800
-#: activate/dev_manager.c:1809 activate/dev_manager.c:1818
-#: activate/dev_manager.c:1827 activate/dev_manager.c:1832
-#: activate/dev_manager.c:1837 activate/dev_manager.c:1849
-#: activate/dev_manager.c:1859 activate/dev_manager.c:1865
-#: activate/dev_manager.c:1901 activate/dev_manager.c:1906
-#: activate/dev_manager.c:1938 activate/dev_manager.c:1956
-#: activate/dev_manager.c:2132 activate/dev_manager.c:2144
-#: activate/dev_manager.c:2150 activate/dev_manager.c:2164
-#: activate/dev_manager.c:2169 activate/dev_manager.c:2176
-#: activate/dev_manager.c:2184 activate/dev_manager.c:2192
-#: activate/dev_manager.c:2198 activate/dev_manager.c:2205
-#: activate/dev_manager.c:2210 activate/dev_manager.c:2238 activate/fs.c:234
-#: activate/fs.c:241 activate/fs.c:248 activate/fs.c:251 activate/fs.c:325
+#: activate/activate.c:74 activate/activate.c:91 activate/activate.c:109
+#: activate/activate.c:364 activate/activate.c:417 activate/activate.c:438
+#: activate/activate.c:445 activate/activate.c:492 activate/activate.c:495
+#: activate/activate.c:514 activate/activate.c:520 activate/activate.c:523
+#: activate/activate.c:536 activate/activate.c:548 activate/activate.c:561
+#: activate/activate.c:564 activate/activate.c:576 activate/activate.c:579
+#: activate/activate.c:591 activate/activate.c:594 activate/activate.c:606
+#: activate/activate.c:609 activate/activate.c:764 activate/activate.c:768
+#: activate/activate.c:776 activate/activate.c:785 activate/activate.c:791
+#: activate/activate.c:836 activate/activate.c:848 activate/activate.c:882
+#: activate/activate.c:894 activate/activate.c:953 activate/activate.c:967
+#: activate/activate.c:996 activate/dev_manager.c:104
+#: activate/dev_manager.c:130 activate/dev_manager.c:139
+#: activate/dev_manager.c:142 activate/dev_manager.c:168
+#: activate/dev_manager.c:176 activate/dev_manager.c:250
+#: activate/dev_manager.c:258 activate/dev_manager.c:261
+#: activate/dev_manager.c:339 activate/dev_manager.c:347
+#: activate/dev_manager.c:350 activate/dev_manager.c:379
+#: activate/dev_manager.c:434 activate/dev_manager.c:439
+#: activate/dev_manager.c:452 activate/dev_manager.c:489
+#: activate/dev_manager.c:492 activate/dev_manager.c:500
+#: activate/dev_manager.c:523 activate/dev_manager.c:535
+#: activate/dev_manager.c:611 activate/dev_manager.c:628
+#: activate/dev_manager.c:631 activate/dev_manager.c:654
+#: activate/dev_manager.c:658 activate/dev_manager.c:661
+#: activate/dev_manager.c:664 activate/dev_manager.c:682
+#: activate/dev_manager.c:689 activate/dev_manager.c:698
+#: activate/dev_manager.c:737 activate/dev_manager.c:757
+#: activate/dev_manager.c:760 activate/dev_manager.c:780
+#: activate/dev_manager.c:783 activate/dev_manager.c:788
+#: activate/dev_manager.c:842 activate/dev_manager.c:851
+#: activate/dev_manager.c:854 activate/dev_manager.c:860
+#: activate/dev_manager.c:866 activate/dev_manager.c:869
+#: activate/dev_manager.c:871 activate/dev_manager.c:877
+#: activate/dev_manager.c:891 activate/dev_manager.c:894
+#: activate/dev_manager.c:920 activate/dev_manager.c:929
+#: activate/dev_manager.c:996 activate/dev_manager.c:1010
+#: activate/dev_manager.c:1018 activate/dev_manager.c:1025
+#: activate/dev_manager.c:1030 activate/dev_manager.c:1038
+#: activate/dev_manager.c:1044 activate/dev_manager.c:1048
+#: activate/dev_manager.c:1052 activate/dev_manager.c:1075
+#: activate/dev_manager.c:1138 activate/fs.c:179 activate/fs.c:229
+#: activate/fs.c:236 activate/fs.c:243 activate/fs.c:246 activate/fs.c:320
 #: archiver.c:68 archiver.c:75 archiver.c:87 archiver.c:163 archiver.c:236
 #: archiver.c:286 archiver.c:303 archiver.c:345 archiver.c:350
-#: cache/lvmcache.c:474 cache/lvmcache.c:515 cache/lvmcache.c:546
+#: cache/lvmcache.c:486 cache/lvmcache.c:490 cache/lvmcache.c:704
+#: cache/lvmcache.c:724 cache/lvmcache.c:750 cache/lvmcache.c:810
 #: commands/toolcontext.c:276 commands/toolcontext.c:295
 #: commands/toolcontext.c:302 commands/toolcontext.c:379
 #: commands/toolcontext.c:394 commands/toolcontext.c:418
-#: commands/toolcontext.c:469 commands/toolcontext.c:662
-#: commands/toolcontext.c:758 config/config.c:105 config/config.c:110
-#: config/config.c:140 config/config.c:161 config/config.c:192
-#: config/config.c:239 config/config.c:244 config/config.c:406
-#: config/config.c:424 config/config.c:429 config/config.c:439
-#: config/config.c:453 config/config.c:469 config/config.c:525
-#: config/config.c:708 datastruct/btree.c:90 datastruct/hash.c:96
-#: datastruct/hash.c:109 datastruct/str_list.c:24 datastruct/str_list.c:38
-#: datastruct/str_list.c:47 datastruct/str_list.c:77 device/dev-cache.c:204
-#: device/dev-cache.c:217 device/dev-cache.c:262 device/dev-cache.c:266
-#: device/dev-cache.c:337 device/dev-cache.c:368 device/dev-cache.c:407
-#: device/dev-cache.c:453 device/dev-cache.c:458 device/dev-io.c:174
-#: device/dev-io.c:204 device/dev-io.c:348 device/dev-io.c:516
-#: device/dev-io.c:537 device/dev-io.c:555 device/dev-io.c:574
-#: device/dev-io.c:602 device/dev-md.c:41 device/dev-md.c:49
-#: device/dev-md.c:64 device/device.c:61 device/device.c:66 device/device.c:90
-#: display/display.c:211 display/display.c:242 display/display.c:300
-#: display/display.c:346 display/display.c:577 display/display.c:613
-#: error/errseg.c:90 filters/filter-composite.c:54
-#: filters/filter-persistent.c:45 filters/filter-persistent.c:105
-#: filters/filter-persistent.c:110 filters/filter-persistent.c:239
-#: filters/filter-persistent.c:245 filters/filter-persistent.c:257
-#: filters/filter-regex.c:78 filters/filter-regex.c:105
-#: filters/filter-regex.c:126 filters/filter-regex.c:151
-#: filters/filter-regex.c:210 filters/filter-regex.c:215
-#: filters/filter-regex.c:222 filters/filter-regex.c:227
-#: filters/filter-sysfs.c:285 filters/filter.c:254 format1/disk-rep.c:220
-#: format1/disk-rep.c:232 format1/disk-rep.c:237 format1/disk-rep.c:256
-#: format1/disk-rep.c:259 format1/disk-rep.c:290 format1/disk-rep.c:293
-#: format1/disk-rep.c:312 format1/disk-rep.c:315 format1/disk-rep.c:332
-#: format1/disk-rep.c:342 format1/disk-rep.c:348 format1/disk-rep.c:413
-#: format1/disk-rep.c:420 format1/disk-rep.c:511 format1/disk-rep.c:532
-#: format1/disk-rep.c:544 format1/disk-rep.c:572 format1/disk-rep.c:586
-#: format1/disk-rep.c:619 format1/disk-rep.c:684 format1/disk-rep.c:691
-#: format1/disk-rep.c:707 format1/format1.c:174 format1/format1.c:189
-#: format1/format1.c:198 format1/format1.c:203 format1/format1.c:220
-#: format1/format1.c:234 format1/format1.c:252 format1/format1.c:263
-#: format1/format1.c:278 format1/format1.c:304 format1/format1.c:309
-#: format1/format1.c:314 format1/format1.c:319 format1/format1.c:356
-#: format1/format1.c:403 format1/format1.c:419 format1/format1.c:424
-#: format1/format1.c:431 format1/format1.c:443 format1/format1.c:494
-#: format1/format1.c:514 format1/format1.c:523 format1/format1.c:567
-#: format1/import-export.c:62 format1/import-export.c:96
-#: format1/import-export.c:128 format1/import-export.c:148
-#: format1/import-export.c:165 format1/import-export.c:173
-#: format1/import-export.c:208 format1/import-export.c:213
-#: format1/import-export.c:218 format1/import-export.c:296
-#: format1/import-export.c:428 format1/import-export.c:433
-#: format1/import-export.c:454 format1/import-export.c:461
-#: format1/import-export.c:483 format1/import-export.c:504
-#: format1/import-export.c:509 format1/import-export.c:518
-#: format1/import-export.c:528 format1/import-export.c:538
-#: format1/import-export.c:543 format1/import-export.c:646
-#: format1/import-export.c:694 format1/import-extents.c:65
-#: format1/import-extents.c:72 format1/import-extents.c:77
-#: format1/import-extents.c:130 format1/import-extents.c:196
-#: format1/import-extents.c:210 format1/import-extents.c:231
-#: format1/import-extents.c:280 format1/import-extents.c:312
-#: format1/import-extents.c:338 format1/import-extents.c:354
-#: format1/import-extents.c:369 format1/layout.c:124 format1/lvm1-label.c:66
-#: format1/vg_number.c:38 format1/vg_number.c:43 format_pool/disk_rep.c:51
-#: format_pool/disk_rep.c:104 format_pool/disk_rep.c:258
-#: format_pool/disk_rep.c:360 format_pool/disk_rep.c:370
-#: format_pool/disk_rep.c:375 format_pool/format_pool.c:134
-#: format_pool/format_pool.c:139 format_pool/format_pool.c:144
-#: format_pool/format_pool.c:154 format_pool/format_pool.c:163
-#: format_pool/format_pool.c:168 format_pool/format_pool.c:188
-#: format_pool/format_pool.c:197 format_pool/format_pool.c:203
-#: format_pool/format_pool.c:233 format_pool/format_pool.c:238
-#: format_pool/format_pool.c:248 format_pool/format_pool.c:253
-#: format_pool/import_export.c:94 format_pool/import_export.c:180
-#: format_pool/import_export.c:218 format_pool/import_export.c:232
-#: format_pool/import_export.c:256 format_pool/import_export.c:276
-#: format_pool/import_export.c:304 format_pool/import_export.c:309
-#: format_text/archive.c:119 format_text/archive.c:140
-#: format_text/archive.c:167 format_text/archive.c:259
-#: format_text/archive.c:270 format_text/archive.c:346
-#: format_text/archive.c:366 format_text/archiver.c:82
-#: format_text/archiver.c:89 format_text/archiver.c:101
-#: format_text/archiver.c:189 format_text/archiver.c:267
-#: format_text/archiver.c:317 format_text/archiver.c:334
-#: format_text/archiver.c:376 format_text/archiver.c:381
-#: format_text/export.c:113 format_text/export.c:178 format_text/export.c:188
-#: format_text/export.c:279 format_text/export.c:280 format_text/export.c:281
-#: format_text/export.c:282 format_text/export.c:284 format_text/export.c:285
-#: format_text/export.c:288 format_text/export.c:289 format_text/export.c:299
-#: format_text/export.c:303 format_text/export.c:305 format_text/export.c:308
-#: format_text/export.c:311 format_text/export.c:315 format_text/export.c:318
-#: format_text/export.c:322 format_text/export.c:326 format_text/export.c:329
-#: format_text/export.c:330 format_text/export.c:334 format_text/export.c:336
-#: format_text/export.c:360 format_text/export.c:367 format_text/export.c:371
-#: format_text/export.c:372 format_text/export.c:376 format_text/export.c:380
-#: format_text/export.c:382 format_text/export.c:385 format_text/export.c:388
-#: format_text/export.c:391 format_text/export.c:395 format_text/export.c:398
-#: format_text/export.c:401 format_text/export.c:404 format_text/export.c:409
-#: format_text/export.c:413 format_text/export.c:422 format_text/export.c:425
-#: format_text/export.c:428 format_text/export.c:432 format_text/export.c:433
-#: format_text/export.c:437 format_text/export.c:440 format_text/export.c:445
-#: format_text/export.c:450 format_text/export.c:461 format_text/export.c:463
-#: format_text/export.c:470 format_text/export.c:476 format_text/export.c:482
-#: format_text/export.c:490 format_text/export.c:500 format_text/export.c:501
-#: format_text/export.c:506 format_text/export.c:510 format_text/export.c:513
-#: format_text/export.c:516 format_text/export.c:520 format_text/export.c:523
-#: format_text/export.c:528 format_text/export.c:531 format_text/export.c:533
-#: format_text/export.c:535 format_text/export.c:536 format_text/export.c:537
-#: format_text/export.c:542 format_text/export.c:548 format_text/export.c:563
-#: format_text/export.c:573 format_text/export.c:582 format_text/export.c:588
-#: format_text/export.c:606 format_text/export.c:611 format_text/export.c:620
-#: format_text/export.c:625 format_text/export.c:630 format_text/export.c:653
-#: format_text/export.c:659 format_text/export.c:662 format_text/export.c:667
-#: format_text/export.c:669 format_text/export.c:671 format_text/export.c:673
-#: format_text/export.c:675 format_text/export.c:679 format_text/export.c:682
-#: format_text/export.c:705 format_text/export.c:732 format_text/export.c:750
-#: format_text/flags.c:91 format_text/flags.c:135
-#: format_text/format-text.c:128 format_text/format-text.c:176
-#: format_text/format-text.c:203 format_text/format-text.c:244
-#: format_text/format-text.c:249 format_text/format-text.c:257
-#: format_text/format-text.c:275 format_text/format-text.c:280
-#: format_text/format-text.c:305 format_text/format-text.c:315
-#: format_text/format-text.c:362 format_text/format-text.c:367
-#: format_text/format-text.c:402 format_text/format-text.c:415
-#: format_text/format-text.c:432 format_text/format-text.c:463
-#: format_text/format-text.c:494 format_text/format-text.c:532
-#: format_text/format-text.c:546 format_text/format-text.c:551
-#: format_text/format-text.c:574 format_text/format-text.c:588
-#: format_text/format-text.c:833 format_text/format-text.c:838
-#: format_text/format-text.c:847 format_text/format-text.c:858
-#: format_text/format-text.c:871 format_text/format-text.c:1063
-#: format_text/format-text.c:1119 format_text/format-text.c:1124
-#: format_text/format-text.c:1134 format_text/format-text.c:1136
-#: format_text/format-text.c:1144 format_text/format-text.c:1184
-#: format_text/format-text.c:1190 format_text/format-text.c:1366
-#: format_text/format-text.c:1372 format_text/format-text.c:1391
-#: format_text/format-text.c:1426 format_text/format-text.c:1445
-#: format_text/format-text.c:1461 format_text/format-text.c:1466
-#: format_text/format-text.c:1480 format_text/format-text.c:1492
-#: format_text/format-text.c:1498 format_text/format-text.c:1529
-#: format_text/format-text.c:1534 format_text/format-text.c:1539
-#: format_text/format-text.c:1548 format_text/format-text.c:1651
-#: format_text/import.c:53 format_text/import.c:72
-#: format_text/import_vsn1.c:124 format_text/import_vsn1.c:135
-#: format_text/import_vsn1.c:168 format_text/import_vsn1.c:214
-#: format_text/import_vsn1.c:280 format_text/import_vsn1.c:286
-#: format_text/import_vsn1.c:299 format_text/import_vsn1.c:364
-#: format_text/import_vsn1.c:406 format_text/import_vsn1.c:434
-#: format_text/import_vsn1.c:442 format_text/import_vsn1.c:459
-#: format_text/import_vsn1.c:466 format_text/import_vsn1.c:495
-#: format_text/import_vsn1.c:553 format_text/import_vsn1.c:606
-#: format_text/import_vsn1.c:631 format_text/import_vsn1.c:641
-#: format_text/import_vsn1.c:646 format_text/import_vsn1.c:716
-#: format_text/tags.c:29 format_text/tags.c:36 format_text/tags.c:43
-#: format_text/tags.c:49 format_text/tags.c:68 label/label.c:91
-#: label/label.c:122 label/label.c:193 label/label.c:214 label/label.c:265
-#: label/label.c:279 label/label.c:314 label/label.c:322 label/label.c:334
-#: label/label.c:346 locking/cluster_locking.c:85
-#: locking/cluster_locking.c:424 locking/cluster_locking.c:436
-#: locking/cluster_locking.c:440 locking/external_locking.c:76 lvchange.c:49
-#: lvchange.c:87 lvchange.c:93 lvchange.c:107 lvchange.c:114 lvchange.c:121
-#: lvchange.c:171 lvchange.c:179 lvchange.c:213 lvchange.c:298 lvchange.c:356
-#: lvchange.c:364 lvconvert.c:43 lvconvert.c:73 lvconvert.c:90 lvconvert.c:219
-#: lvcreate.c:141 lvcreate.c:309 lvcreate.c:333 lvcreate.c:349 lvcreate.c:469
-#: lvcreate.c:557 lvcreate.c:611 lvcreate.c:618 lvcreate.c:623 lvcreate.c:629
-#: lvcreate.c:636 lvcreate.c:663 lvcreate.c:703 lvcreate.c:711 lvcreate.c:717
-#: lvcreate.c:724 lvcreate.c:814 lvmcmdline.c:946 lvremove.c:86 lvrename.c:87
-#: lvrename.c:144 lvrename.c:155 lvrename.c:162 lvrename.c:167 lvresize.c:417
-#: lvresize.c:474 lvresize.c:481 lvresize.c:488 lvresize.c:500 lvresize.c:507
-#: lvresize.c:513 lvresize.c:532 lvresize.c:546 lvresize.c:571
-#: metadata/lv_manip.c:73 metadata/lv_manip.c:171 metadata/lv_manip.c:206
-#: metadata/lv_manip.c:272 metadata/lv_manip.c:281 metadata/lv_manip.c:296
-#: metadata/lv_manip.c:305 metadata/lv_manip.c:332 metadata/lv_manip.c:468
-#: metadata/lv_manip.c:476 metadata/lv_manip.c:511 metadata/lv_manip.c:720
-#: metadata/lv_manip.c:768 metadata/lv_manip.c:793 metadata/lv_manip.c:805
-#: metadata/lv_manip.c:816 metadata/lv_manip.c:897 metadata/lv_manip.c:905
-#: metadata/lv_manip.c:942 metadata/lv_manip.c:954 metadata/lv_manip.c:983
-#: metadata/lv_manip.c:993 metadata/lv_manip.c:1039 metadata/lv_manip.c:1069
-#: metadata/lv_manip.c:1076 metadata/lv_manip.c:1189 metadata/merge.c:207
-#: metadata/merge.c:246 metadata/merge.c:251 metadata/metadata.c:105
-#: metadata/metadata.c:131 metadata/metadata.c:158 metadata/metadata.c:228
-#: metadata/metadata.c:252 metadata/metadata.c:346 metadata/metadata.c:352
-#: metadata/metadata.c:358 metadata/metadata.c:369 metadata/metadata.c:375
-#: metadata/metadata.c:387 metadata/metadata.c:393 metadata/metadata.c:405
-#: metadata/metadata.c:413 metadata/metadata.c:420 metadata/metadata.c:427
-#: metadata/metadata.c:434 metadata/metadata.c:447 metadata/metadata.c:455
-#: metadata/metadata.c:464 metadata/metadata.c:495 metadata/metadata.c:510
-#: metadata/metadata.c:692 metadata/metadata.c:731 metadata/metadata.c:759
-#: metadata/metadata.c:765 metadata/metadata.c:772 metadata/metadata.c:783
-#: metadata/metadata.c:788 metadata/metadata.c:810 metadata/metadata.c:832
-#: metadata/metadata.c:849 metadata/metadata.c:915 metadata/metadata.c:920
-#: metadata/metadata.c:965 metadata/metadata.c:1005 metadata/metadata.c:1188
-#: metadata/metadata.c:1222 metadata/metadata.c:1274 metadata/metadata.c:1307
-#: metadata/mirror.c:34 metadata/mirror.c:53 metadata/mirror.c:58
-#: metadata/mirror.c:72 metadata/mirror.c:186 metadata/mirror.c:225
-#: metadata/mirror.c:234 metadata/mirror.c:362 metadata/mirror.c:383
-#: metadata/mirror.c:388 metadata/mirror.c:462 metadata/pv_manip.c:55
-#: metadata/pv_manip.c:74 metadata/pv_manip.c:95 metadata/pv_manip.c:132
-#: metadata/pv_manip.c:157 metadata/pv_manip.c:198 metadata/pv_map.c:42
-#: metadata/pv_map.c:90 metadata/pv_map.c:110 metadata/pv_map.c:120
-#: metadata/pv_map.c:138 metadata/pv_map.c:148 metadata/snapshot_manip.c:56
-#: metadata/snapshot_manip.c:63 mirror/mirrored.c:137 mirror/mirrored.c:142
-#: mirror/mirrored.c:144 mirror/mirrored.c:225 mirror/mirrored.c:305
-#: misc/lvm-string.c:152 pvchange.c:185 pvmove.c:98 pvmove.c:103 pvmove.c:188
-#: pvmove.c:216 pvmove.c:223 pvmove.c:287 pvmove.c:294 pvmove.c:303
-#: pvmove.c:332 pvmove.c:345 pvmove.c:352 pvmove.c:359 pvmove.c:367
-#: pvmove.c:379 pvmove.c:520 pvscan.c:54 regex/matcher.c:182
-#: regex/matcher.c:203 regex/matcher.c:208 regex/matcher.c:282
-#: regex/matcher.c:287 regex/matcher.c:300 regex/matcher.c:322
-#: regex/parse_rx.c:229 regex/parse_rx.c:280 regex/parse_rx.c:305
-#: regex/parse_rx.c:328 regex/parse_rx.c:340 regex/ttree.c:91
-#: regex/ttree.c:111 report/report.c:576 report/report.c:604
-#: report/report.c:736 snapshot/snapshot.c:75 snapshot/snapshot.c:84
-#: snapshot/snapshot.c:85 snapshot/snapshot.c:86 snapshot/snapshot.c:155
-#: striped/striped.c:92 striped/striped.c:171 striped/striped.c:220
-#: toollib.c:760 toollib.c:810 toollib.c:857 uuid/uuid.c:91 uuid/uuid.c:95
-#: vgcfgbackup.c:65 vgcfgbackup.c:74 vgcfgbackup.c:81 vgchange.c:302
-#: vgmerge.c:160 vgreduce.c:28 vgreduce.c:90 vgreduce.c:96 vgreduce.c:104
-#: vgreduce.c:140 vgreduce.c:156 zero/zero.c:90
+#: commands/toolcontext.c:469 commands/toolcontext.c:685
+#: commands/toolcontext.c:781 config/config.c:148 config/config.c:161
+#: config/config.c:176 config/config.c:194 config/config.c:215
+#: config/config.c:235 config/config.c:282 config/config.c:285
+#: config/config.c:467 config/config.c:485 config/config.c:490
+#: config/config.c:500 config/config.c:514 config/config.c:530
+#: config/config.c:586 config/config.c:777 datastruct/btree.c:90
+#: datastruct/str_list.c:24 datastruct/str_list.c:38 datastruct/str_list.c:47
+#: datastruct/str_list.c:77 device/dev-cache.c:240 device/dev-cache.c:253
+#: device/dev-cache.c:298 device/dev-cache.c:302 device/dev-cache.c:373
+#: device/dev-cache.c:404 device/dev-cache.c:443 device/dev-cache.c:511
+#: device/dev-cache.c:547 device/dev-cache.c:552 device/dev-cache.c:567
+#: device/dev-io.c:174 device/dev-io.c:204 device/dev-io.c:358
+#: device/dev-io.c:556 device/dev-io.c:606 device/dev-io.c:624
+#: device/dev-io.c:643 device/dev-io.c:671 device/dev-md.c:41
+#: device/dev-md.c:49 device/dev-md.c:66 device/device.c:61 device/device.c:66
+#: device/device.c:90 display/display.c:243 display/display.c:274
+#: display/display.c:333 display/display.c:379 display/display.c:605
+#: display/display.c:641 error/errseg.c:101 filters/filter-composite.c:54
+#: filters/filter-persistent.c:46 filters/filter-persistent.c:110
+#: filters/filter-persistent.c:114 filters/filter-persistent.c:117
+#: filters/filter-persistent.c:197 filters/filter-persistent.c:299
+#: filters/filter-persistent.c:305 filters/filter-persistent.c:316
+#: filters/filter-regex.c:74 filters/filter-regex.c:101
+#: filters/filter-regex.c:119 filters/filter-regex.c:142
+#: filters/filter-regex.c:196 filters/filter-regex.c:201
+#: filters/filter-regex.c:206 filters/filter-regex.c:209
+#: filters/filter-sysfs.c:288 filters/filter.c:278 format1/disk-rep.c:221
+#: format1/disk-rep.c:233 format1/disk-rep.c:238 format1/disk-rep.c:257
+#: format1/disk-rep.c:260 format1/disk-rep.c:291 format1/disk-rep.c:294
+#: format1/disk-rep.c:313 format1/disk-rep.c:316 format1/disk-rep.c:334
+#: format1/disk-rep.c:351 format1/disk-rep.c:361 format1/disk-rep.c:421
+#: format1/disk-rep.c:428 format1/disk-rep.c:522 format1/disk-rep.c:547
+#: format1/disk-rep.c:563 format1/disk-rep.c:591 format1/disk-rep.c:609
+#: format1/disk-rep.c:646 format1/disk-rep.c:711 format1/disk-rep.c:718
+#: format1/disk-rep.c:734 format1/format1.c:134 format1/format1.c:137
+#: format1/format1.c:149 format1/format1.c:154 format1/format1.c:157
+#: format1/format1.c:160 format1/format1.c:163 format1/format1.c:166
+#: format1/format1.c:171 format1/format1.c:186 format1/format1.c:195
+#: format1/format1.c:198 format1/format1.c:213 format1/format1.c:227
+#: format1/format1.c:245 format1/format1.c:256 format1/format1.c:271
+#: format1/format1.c:297 format1/format1.c:302 format1/format1.c:307
+#: format1/format1.c:312 format1/format1.c:348 format1/format1.c:394
+#: format1/format1.c:410 format1/format1.c:415 format1/format1.c:421
+#: format1/format1.c:431 format1/format1.c:477 format1/format1.c:498
+#: format1/format1.c:507 format1/format1.c:551 format1/import-export.c:63
+#: format1/import-export.c:118 format1/import-export.c:151
+#: format1/import-export.c:168 format1/import-export.c:185
+#: format1/import-export.c:193 format1/import-export.c:228
+#: format1/import-export.c:233 format1/import-export.c:238
+#: format1/import-export.c:316 format1/import-export.c:448
+#: format1/import-export.c:453 format1/import-export.c:474
+#: format1/import-export.c:481 format1/import-export.c:503
+#: format1/import-export.c:524 format1/import-export.c:529
+#: format1/import-export.c:538 format1/import-export.c:548
+#: format1/import-export.c:558 format1/import-export.c:563
+#: format1/import-export.c:666 format1/import-export.c:714
+#: format1/import-extents.c:63 format1/import-extents.c:68
+#: format1/import-extents.c:71 format1/import-extents.c:122
+#: format1/import-extents.c:193 format1/import-extents.c:220
+#: format1/import-extents.c:235 format1/import-extents.c:284
+#: format1/import-extents.c:314 format1/import-extents.c:338
+#: format1/import-extents.c:354 format1/import-extents.c:369
+#: format1/layout.c:126 format1/lvm1-label.c:75 format1/vg_number.c:37
+#: format1/vg_number.c:42 format_pool/disk_rep.c:49 format_pool/disk_rep.c:102
+#: format_pool/disk_rep.c:256 format_pool/disk_rep.c:358
+#: format_pool/disk_rep.c:368 format_pool/disk_rep.c:373
+#: format_pool/format_pool.c:132 format_pool/format_pool.c:137
+#: format_pool/format_pool.c:142 format_pool/format_pool.c:152
+#: format_pool/format_pool.c:161 format_pool/format_pool.c:166
+#: format_pool/format_pool.c:186 format_pool/format_pool.c:195
+#: format_pool/format_pool.c:201 format_pool/format_pool.c:231
+#: format_pool/format_pool.c:236 format_pool/format_pool.c:246
+#: format_pool/format_pool.c:251 format_pool/import_export.c:93
+#: format_pool/import_export.c:180 format_pool/import_export.c:218
+#: format_pool/import_export.c:232 format_pool/import_export.c:256
+#: format_pool/import_export.c:276 format_pool/import_export.c:304
+#: format_pool/import_export.c:309 format_text/archive.c:117
+#: format_text/archive.c:138 format_text/archive.c:165
+#: format_text/archive.c:258 format_text/archive.c:274
+#: format_text/archive.c:350 format_text/archive.c:370
+#: format_text/archiver.c:82 format_text/archiver.c:89
+#: format_text/archiver.c:101 format_text/archiver.c:189
+#: format_text/archiver.c:267 format_text/archiver.c:317
+#: format_text/archiver.c:334 format_text/archiver.c:376
+#: format_text/archiver.c:381 format_text/export.c:138
+#: format_text/export.c:198 format_text/export.c:206 format_text/export.c:293
+#: format_text/export.c:294 format_text/export.c:295 format_text/export.c:296
+#: format_text/export.c:298 format_text/export.c:299 format_text/export.c:300
+#: format_text/export.c:303 format_text/export.c:313 format_text/export.c:317
+#: format_text/export.c:319 format_text/export.c:322 format_text/export.c:325
+#: format_text/export.c:329 format_text/export.c:332 format_text/export.c:336
+#: format_text/export.c:340 format_text/export.c:343 format_text/export.c:344
+#: format_text/export.c:348 format_text/export.c:349 format_text/export.c:373
+#: format_text/export.c:380 format_text/export.c:384 format_text/export.c:385
+#: format_text/export.c:389 format_text/export.c:393 format_text/export.c:395
+#: format_text/export.c:398 format_text/export.c:401 format_text/export.c:404
+#: format_text/export.c:408 format_text/export.c:411 format_text/export.c:415
+#: format_text/export.c:419 format_text/export.c:422 format_text/export.c:427
+#: format_text/export.c:431 format_text/export.c:440 format_text/export.c:443
+#: format_text/export.c:446 format_text/export.c:450 format_text/export.c:451
+#: format_text/export.c:455 format_text/export.c:458 format_text/export.c:463
+#: format_text/export.c:468 format_text/export.c:479 format_text/export.c:481
+#: format_text/export.c:488 format_text/export.c:492 format_text/export.c:497
+#: format_text/export.c:508 format_text/export.c:518 format_text/export.c:519
+#: format_text/export.c:524 format_text/export.c:528 format_text/export.c:531
+#: format_text/export.c:534 format_text/export.c:538 format_text/export.c:541
+#: format_text/export.c:545 format_text/export.c:549 format_text/export.c:551
+#: format_text/export.c:553 format_text/export.c:554 format_text/export.c:555
+#: format_text/export.c:560 format_text/export.c:566 format_text/export.c:581
+#: format_text/export.c:591 format_text/export.c:600 format_text/export.c:606
+#: format_text/export.c:624 format_text/export.c:627 format_text/export.c:634
+#: format_text/export.c:637 format_text/export.c:640 format_text/export.c:652
+#: format_text/export.c:657 format_text/export.c:660 format_text/export.c:665
+#: format_text/export.c:667 format_text/export.c:669 format_text/export.c:671
+#: format_text/export.c:673 format_text/export.c:677 format_text/export.c:680
+#: format_text/export.c:702 format_text/export.c:729 format_text/export.c:747
+#: format_text/flags.c:94 format_text/flags.c:138
+#: format_text/format-text.c:158 format_text/format-text.c:161
+#: format_text/format-text.c:195 format_text/format-text.c:199
+#: format_text/format-text.c:238 format_text/format-text.c:295
+#: format_text/format-text.c:346 format_text/format-text.c:378
+#: format_text/format-text.c:420 format_text/format-text.c:425
+#: format_text/format-text.c:433 format_text/format-text.c:451
+#: format_text/format-text.c:456 format_text/format-text.c:481
+#: format_text/format-text.c:494 format_text/format-text.c:542
+#: format_text/format-text.c:547 format_text/format-text.c:587
+#: format_text/format-text.c:601 format_text/format-text.c:619
+#: format_text/format-text.c:650 format_text/format-text.c:700
+#: format_text/format-text.c:757 format_text/format-text.c:762
+#: format_text/format-text.c:785 format_text/format-text.c:799
+#: format_text/format-text.c:1059 format_text/format-text.c:1064
+#: format_text/format-text.c:1072 format_text/format-text.c:1082
+#: format_text/format-text.c:1103 format_text/format-text.c:1107
+#: format_text/format-text.c:1113 format_text/format-text.c:1125
+#: format_text/format-text.c:1309 format_text/format-text.c:1365
+#: format_text/format-text.c:1370 format_text/format-text.c:1380
+#: format_text/format-text.c:1382 format_text/format-text.c:1390
+#: format_text/format-text.c:1430 format_text/format-text.c:1436
+#: format_text/format-text.c:1621 format_text/format-text.c:1627
+#: format_text/format-text.c:1666 format_text/format-text.c:1711
+#: format_text/format-text.c:1730 format_text/format-text.c:1746
+#: format_text/format-text.c:1751 format_text/format-text.c:1765
+#: format_text/format-text.c:1777 format_text/format-text.c:1783
+#: format_text/format-text.c:1813 format_text/format-text.c:1818
+#: format_text/format-text.c:1823 format_text/format-text.c:1832
+#: format_text/format-text.c:1935 format_text/import.c:47
+#: format_text/import.c:52 format_text/import.c:63 format_text/import.c:98
+#: format_text/import.c:115 format_text/import_vsn1.c:123
+#: format_text/import_vsn1.c:134 format_text/import_vsn1.c:167
+#: format_text/import_vsn1.c:237 format_text/import_vsn1.c:303
+#: format_text/import_vsn1.c:309 format_text/import_vsn1.c:322
+#: format_text/import_vsn1.c:387 format_text/import_vsn1.c:429
+#: format_text/import_vsn1.c:457 format_text/import_vsn1.c:465
+#: format_text/import_vsn1.c:482 format_text/import_vsn1.c:489
+#: format_text/import_vsn1.c:518 format_text/import_vsn1.c:576
+#: format_text/import_vsn1.c:629 format_text/import_vsn1.c:654
+#: format_text/import_vsn1.c:664 format_text/import_vsn1.c:667
+#: format_text/import_vsn1.c:735 format_text/import_vsn1.c:846
+#: format_text/tags.c:28 format_text/tags.c:35 format_text/tags.c:42
+#: format_text/tags.c:48 format_text/tags.c:67 format_text/text_label.c:210
+#: format_text/text_label.c:246 label/label.c:90 label/label.c:207
+#: label/label.c:258 label/label.c:274 label/label.c:284 label/label.c:291
+#: label/label.c:321 label/label.c:329 label/label.c:341 label/label.c:360
+#: label/label.c:364 label/label.c:370 locking/cluster_locking.c:85
+#: locking/cluster_locking.c:420 locking/cluster_locking.c:432
+#: locking/cluster_locking.c:436 locking/external_locking.c:77 lvchange.c:57
+#: lvchange.c:99 lvchange.c:116 lvchange.c:122 lvchange.c:136 lvchange.c:143
+#: lvchange.c:150 lvchange.c:268 lvchange.c:282 lvchange.c:353 lvchange.c:361
+#: lvchange.c:395 lvchange.c:472 lvchange.c:479 lvchange.c:526 lvchange.c:534
+#: lvconvert.c:96 lvconvert.c:147 lvconvert.c:211 lvconvert.c:222
+#: lvconvert.c:273 lvconvert.c:285 lvconvert.c:298 lvconvert.c:332
+#: lvconvert.c:354 lvconvert.c:369 lvconvert.c:378 lvconvert.c:397
+#: lvconvert.c:404 lvconvert.c:470 lvconvert.c:481 lvconvert.c:544
+#: lvconvert.c:585 lvcreate.c:133 lvcreate.c:349 lvcreate.c:373 lvcreate.c:399
+#: lvcreate.c:529 lvcreate.c:661 lvcreate.c:698 lvcreate.c:728 lvcreate.c:755
+#: lvcreate.c:763 lvcreate.c:769 lvcreate.c:776 lvcreate.c:868
+#: lvmcmdline.c:830 lvmcmdline.c:836 lvmcmdline.c:839 lvmcmdline.c:842
+#: lvmcmdline.c:846 lvmcmdline.c:853 lvmcmdline.c:885 lvmcmdline.c:896
+#: lvmcmdline.c:906 lvmcmdline.c:936 lvmcmdline.c:1022 lvremove.c:99
+#: lvrename.c:85 lvrename.c:164 lvrename.c:175 lvrename.c:182 lvrename.c:188
+#: lvresize.c:466 lvresize.c:522 lvresize.c:529 lvresize.c:536 lvresize.c:547
+#: lvresize.c:554 lvresize.c:560 lvresize.c:579 lvresize.c:593 lvresize.c:618
+#: metadata/lv_manip.c:85 metadata/lv_manip.c:91 metadata/lv_manip.c:192
+#: metadata/lv_manip.c:227 metadata/lv_manip.c:258 metadata/lv_manip.c:316
+#: metadata/lv_manip.c:325 metadata/lv_manip.c:340 metadata/lv_manip.c:349
+#: metadata/lv_manip.c:379 metadata/lv_manip.c:580 metadata/lv_manip.c:588
+#: metadata/lv_manip.c:623 metadata/lv_manip.c:735 metadata/lv_manip.c:738
+#: metadata/lv_manip.c:748 metadata/lv_manip.c:846 metadata/lv_manip.c:874
+#: metadata/lv_manip.c:1048 metadata/lv_manip.c:1095 metadata/lv_manip.c:1100
+#: metadata/lv_manip.c:1130 metadata/lv_manip.c:1221 metadata/lv_manip.c:1228
+#: metadata/lv_manip.c:1265 metadata/lv_manip.c:1277 metadata/lv_manip.c:1306
+#: metadata/lv_manip.c:1316 metadata/lv_manip.c:1364 metadata/lv_manip.c:1429
+#: metadata/lv_manip.c:1436 metadata/lv_manip.c:1548 metadata/lv_manip.c:1619
+#: metadata/merge.c:253 metadata/merge.c:292 metadata/merge.c:297
+#: metadata/metadata.c:119 metadata/metadata.c:154 metadata/metadata.c:182
+#: metadata/metadata.c:252 metadata/metadata.c:276 metadata/metadata.c:284
+#: metadata/metadata.c:322 metadata/metadata.c:372 metadata/metadata.c:378
+#: metadata/metadata.c:384 metadata/metadata.c:395 metadata/metadata.c:401
+#: metadata/metadata.c:413 metadata/metadata.c:419 metadata/metadata.c:431
+#: metadata/metadata.c:439 metadata/metadata.c:446 metadata/metadata.c:453
+#: metadata/metadata.c:460 metadata/metadata.c:473 metadata/metadata.c:481
+#: metadata/metadata.c:490 metadata/metadata.c:549 metadata/metadata.c:564
+#: metadata/metadata.c:754 metadata/metadata.c:779 metadata/metadata.c:815
+#: metadata/metadata.c:846 metadata/metadata.c:874 metadata/metadata.c:880
+#: metadata/metadata.c:887 metadata/metadata.c:898 metadata/metadata.c:903
+#: metadata/metadata.c:925 metadata/metadata.c:947 metadata/metadata.c:964
+#: metadata/metadata.c:1063 metadata/metadata.c:1068 metadata/metadata.c:1079
+#: metadata/metadata.c:1137 metadata/metadata.c:1142 metadata/metadata.c:1168
+#: metadata/metadata.c:1183 metadata/metadata.c:1191 metadata/metadata.c:1246
+#: metadata/metadata.c:1250 metadata/metadata.c:1399 metadata/metadata.c:1433
+#: metadata/metadata.c:1490 metadata/metadata.c:1494 metadata/metadata.c:1527
+#: metadata/mirror.c:106 metadata/mirror.c:109 metadata/mirror.c:112
+#: metadata/mirror.c:205 metadata/mirror.c:484 metadata/mirror.c:526
+#: metadata/mirror.c:560 metadata/mirror.c:599 metadata/mirror.c:608
+#: metadata/mirror.c:736 metadata/mirror.c:757 metadata/mirror.c:762
+#: metadata/mirror.c:836 metadata/pv_manip.c:54 metadata/pv_manip.c:73
+#: metadata/pv_manip.c:94 metadata/pv_manip.c:131 metadata/pv_manip.c:156
+#: metadata/pv_manip.c:197 metadata/pv_manip.c:332 metadata/pv_map.c:44
+#: metadata/pv_map.c:92 metadata/pv_map.c:112 metadata/pv_map.c:122
+#: metadata/pv_map.c:149 metadata/pv_map.c:159 metadata/snapshot_manip.c:70
+#: metadata/snapshot_manip.c:77 mirror/mirrored.c:144 mirror/mirrored.c:149
+#: mirror/mirrored.c:151 mirror/mirrored.c:304 mirror/mirrored.c:328
+#: mirror/mirrored.c:331 mirror/mirrored.c:501 mirror/mirrored.c:552
+#: misc/lvm-file.c:291 misc/timestamp.c:44 pvchange.c:191 pvmove.c:102
+#: pvmove.c:107 pvmove.c:192 pvmove.c:220 pvmove.c:227 pvmove.c:292
+#: pvmove.c:299 pvmove.c:308 pvmove.c:337 pvmove.c:349 pvmove.c:356
+#: pvmove.c:363 pvmove.c:371 pvmove.c:383 pvmove.c:524 pvresize.c:165
+#: pvscan.c:55 report/report.c:187 report/report.c:513 report/report.c:543
+#: report/report.c:699 reporter.c:289 snapshot/snapshot.c:74
+#: snapshot/snapshot.c:83 snapshot/snapshot.c:84 snapshot/snapshot.c:85
+#: snapshot/snapshot.c:169 striped/striped.c:89 striped/striped.c:169
+#: striped/striped.c:172 striped/striped.c:216 toollib.c:912 toollib.c:962
+#: toollib.c:1020 toollib.c:1060 toollib.c:1085 toollib.c:1194 toollib.c:1332
+#: toollib.c:1337 toollib.c:1350 toollib.c:1357 uuid/uuid.c:90 uuid/uuid.c:94
+#: vgcfgbackup.c:69 vgcfgbackup.c:78 vgcfgbackup.c:85 vgchange.c:420
+#: vgmerge.c:193 vgreduce.c:29 vgreduce.c:96 vgreduce.c:102 vgreduce.c:124
+#: vgreduce.c:130 vgreduce.c:148 vgreduce.c:196 vgreduce.c:217 vgreduce.c:241
+#: vgreduce.c:307 vgreduce.c:353 zero/zero.c:99
 msgid "<backtrace>"
 msgstr ""
 
-#: activate/activate.c:280
-msgid "Failed to get driver version"
-msgstr ""
-
-#: activate/activate.c:302
-#, c-format
-msgid "Getting target version for %s"
-msgstr ""
-
-#: activate/activate.c:309
-#, c-format
-msgid "Failed to get %s target version"
+#: activate/activate.c:81
+msgid "snap_seg module string allocation failed"
 msgstr ""
 
-#: activate/activate.c:563
-#, c-format
-msgid "Skipping: Suspending '%s'."
+#: activate/activate.c:245
+msgid "Activation enabled. Device-mapper kernel driver will be used."
 msgstr ""
 
-#: activate/activate.c:609
-#, c-format
-msgid "Skipping: Resuming '%s'."
+#: activate/activate.c:248
+msgid ""
+"WARNING: Activation disabled. No device-mapper interaction will be attempted."
 msgstr ""
 
-#: activate/activate.c:654
-#, c-format
-msgid "Skipping: Deactivating '%s'."
+#: activate/activate.c:281
+msgid "Ignoring invalid string in config file activation/volume_list"
 msgstr ""
 
-#: activate/activate.c:667
-#, c-format
-msgid "LV %s/%s in use: not removing"
+#: activate/activate.c:287
+msgid "Ignoring empty string in config file activation/volume_list"
 msgstr ""
 
-#: activate/activate.c:693 activate/activate.c:717
-#, c-format
-msgid "Not activating %s/%s due to config file settings"
+#: activate/activate.c:296
+msgid "Ignoring empty tag in config file activation/volume_list"
 msgstr ""
 
-#: activate/activate.c:723
+#: activate/activate.c:326
 #, c-format
-msgid "Skipping: Activating '%s'."
+msgid "dm_snprintf error from %s/%s"
 msgstr ""
 
-#: activate/dev_manager.c:231 activate/dev_manager.c:291
-#: activate/dev_manager.c:372 activate/dev_manager.c:478
-#: activate/dev_manager.c:509 activate/dev_manager.c:603
-#: activate/dev_manager.c:662
-msgid "Failed to disable open_count"
+#: activate/activate.c:350
+msgid "Getting driver version"
 msgstr ""
 
-#: activate/dev_manager.c:392 activate/dev_manager.c:418
+#: activate/activate.c:362
 #, c-format
-msgid "Number of segments in active LV %s does not match metadata"
+msgid "Getting target version for %s"
 msgstr ""
 
-#: activate/dev_manager.c:428
+#: activate/activate.c:367
 #, c-format
-msgid "LV percent: %f"
+msgid "Failed to get %s target version"
 msgstr ""
 
-#: activate/dev_manager.c:460
+#: activate/activate.c:411
 #, c-format
-msgid "Couldn't split up dm layer name %s"
+msgid "target_present module name too long: %s"
 msgstr ""
 
-#: activate/dev_manager.c:464 format_text/format-text.c:681
-#: format_text/format-text.c:706 format_text/format-text.c:740
+#: activate/activate.c:440
 #, c-format
-msgid "Renaming %s to %s"
+msgid "Getting device info for %s"
 msgstr ""
 
-#: activate/dev_manager.c:481
+#: activate/activate.c:771
 #, c-format
-msgid "Couldn't rename device '%s'."
+msgid "Skipping: Suspending '%s'."
 msgstr ""
 
-#: activate/dev_manager.c:502
+#: activate/activate.c:831
 #, c-format
-msgid "%s %s"
+msgid "Skipping: Resuming '%s'."
 msgstr ""
 
-#: activate/dev_manager.c:512
+#: activate/activate.c:877
 #, c-format
-msgid "Couldn't %s device '%s'"
+msgid "Skipping: Deactivating '%s'."
 msgstr ""
 
-#: activate/dev_manager.c:552
+#: activate/activate.c:888
 #, c-format
-msgid "Loading %s"
+msgid "LV %s/%s in use: not deactivating"
 msgstr ""
 
-#: activate/dev_manager.c:563
+#: activate/activate.c:917 activate/activate.c:942
 #, c-format
-msgid "Couldn't populate device '%s'."
+msgid "Not activating %s/%s due to config file settings"
 msgstr ""
 
-#: activate/dev_manager.c:573
+#: activate/activate.c:948
 #, c-format
-msgid "Failed to set major number for %s to %d during activation."
+msgid "Skipping: Activating '%s'."
 msgstr ""
 
-#: activate/dev_manager.c:578
+#: activate/dev_manager.c:75
 #, c-format
-msgid "Set major number for %s to %d."
+msgid "_build_dlid: pool allocation failed for %zu %s %s."
 msgstr ""
 
-#: activate/dev_manager.c:584
-#, c-format
-msgid "Failed to set minor number for %s to %d during activation."
+#: activate/dev_manager.c:136 activate/dev_manager.c:255
+#: activate/dev_manager.c:344
+msgid "Failed to disable open_count"
 msgstr ""
 
-#: activate/dev_manager.c:589
-#, c-format
-msgid "Set minor number for %s to %d."
+#: activate/dev_manager.c:163
+msgid "Failed to allocate dm_task struct to check dev status"
 msgstr ""
 
-#: activate/dev_manager.c:595
-#, c-format
-msgid "Failed to set %s read-only during activation."
+#: activate/dev_manager.c:171
+msgid "Failed to get state of mapped device"
 msgstr ""
 
-#: activate/dev_manager.c:599
+#: activate/dev_manager.c:229 activate/dev_manager.c:528
 #, c-format
-msgid "Activating %s read-only"
+msgid "dlid build failed for %s"
 msgstr ""
 
-#: activate/dev_manager.c:606
+#: activate/dev_manager.c:360 activate/dev_manager.c:384
 #, c-format
-msgid "Couldn't load device '%s'."
+msgid "Number of segments in active LV %s does not match metadata"
 msgstr ""
 
-#: activate/dev_manager.c:609
+#: activate/dev_manager.c:394
 #, c-format
-msgid "Perhaps the persistent device number %d:%d is already in use?"
+msgid "LV percent: %f"
 msgstr ""
 
-#: activate/dev_manager.c:633
+#: activate/dev_manager.c:497
 #, c-format
-msgid "Activated %s %s %03u:%03u"
+msgid "Getting device status percentage for %s"
 msgstr ""
 
-#: activate/dev_manager.c:652 activate/dev_manager.c:654 activate/fs.c:103
-#: activate/fs.c:156 activate/fs.c:169
+#: activate/dev_manager.c:532
 #, c-format
-msgid "Removing %s"
+msgid "Getting device mirror status percentage for %s"
 msgstr ""
 
-#: activate/dev_manager.c:701
+#: activate/dev_manager.c:633
 #, c-format
-msgid "_emit_target: Internal error: Can't handle segment type %s"
+msgid "Getting device info for %s [%s]"
 msgstr ""
 
-#: activate/dev_manager.c:718
+#: activate/dev_manager.c:635
 #, c-format
-msgid "Adding target: %llu %llu %s %s"
+msgid "Failed to get info for %s [%s]."
 msgstr ""
 
-#: activate/dev_manager.c:736
+#: activate/dev_manager.c:640
 #, c-format
-msgid "%s device layer %s missing from hash"
+msgid "Failed to add device (%u:%u) to dtree"
 msgstr ""
 
-#: activate/dev_manager.c:743
+#: activate/dev_manager.c:677
 #, c-format
-msgid "Failed to format %s device number for %s as dm target (%u,%u)"
+msgid "Partial dtree creation failed for %s."
 msgstr ""
 
-#: activate/dev_manager.c:829
+#: activate/dev_manager.c:741
 #, c-format
 msgid "Internal error: Unassigned area found in LV %s."
 msgstr ""
 
-#: activate/dev_manager.c:852
-msgid "Insufficient space for target parameters."
-msgstr ""
-
-#: activate/dev_manager.c:865
-msgid "Insufficient space in params[%zu] for target parameters."
-msgstr ""
-
-#: activate/dev_manager.c:871
-msgid "Target parameter size too big. Aborting."
-msgstr ""
-
-#: activate/dev_manager.c:885
-#, c-format
-msgid "Unable to build table for '%s'"
-msgstr ""
-
-#: activate/dev_manager.c:909
-#, c-format
-msgid "Adding target: 0 %llu snapshot-origin %s"
-msgstr ""
-
-#: activate/dev_manager.c:930
+#: activate/dev_manager.c:775
 #, c-format
 msgid "Couldn't find snapshot for '%s'."
 msgstr ""
 
-#: activate/dev_manager.c:964
-#, c-format
-msgid "Adding target: 0 %llu snapshot %s"
-msgstr ""
-
-#: activate/dev_manager.c:1048 activate/dev_manager.c:1128
+#: activate/dev_manager.c:800
 #, c-format
-msgid "Getting device info for %s"
+msgid "_emit_target: Internal error: Can't handle segment type %s"
 msgstr ""
 
-#: activate/dev_manager.c:1074
+#: activate/dev_manager.c:828
 #, c-format
-msgid "Getting device status percentage for %s"
+msgid "Checking kernel supports %s segment type for %s%s%s"
 msgstr ""
 
-#: activate/dev_manager.c:1105
+#: activate/dev_manager.c:834
 #, c-format
-msgid "Getting device mirror status percentage for %s"
+msgid "Can't expand LV %s: %s target support missing from kernel?"
 msgstr ""
 
-#: activate/dev_manager.c:1405 activate/dev_manager.c:1411
+#: activate/dev_manager.c:847
 msgid "Clustered snapshots are not yet supported"
 msgstr ""
 
-#: activate/dev_manager.c:1448 activate/dev_manager.c:1608
-#, c-format
-msgid "Couldn't find device layer '%s'."
-msgstr ""
-
-#: activate/dev_manager.c:1528
+#: activate/dev_manager.c:902
 #, c-format
-msgid "_suspend_parents couldn't find device layer '%s' - skipping."
+msgid "_add_new_lv_to_dtree: pool alloc failed for %s %s."
 msgstr ""
 
-#: activate/dev_manager.c:1534
+#: activate/dev_manager.c:961
 #, c-format
-msgid "BUG: pre-suspend loop detected (%s)"
+msgid "_create_lv_symlinks: Couldn't split up old device name %s"
 msgstr ""
 
-#: activate/dev_manager.c:1562
+#: activate/dev_manager.c:987
 #, c-format
-msgid "_resume_with_deps couldn't find device layer '%s' - skipping."
+msgid "_clean_tree: Couldn't split up device name %s."
 msgstr ""
 
-#: activate/dev_manager.c:1568 activate/dev_manager.c:1613
-#, c-format
-msgid "BUG: pre-create loop detected (%s)"
-msgstr ""
-
-#: activate/dev_manager.c:1720 activate/dev_manager.c:1736
-#, c-format
-msgid ""
-"_populate_pre_suspend_lists: Couldn't find device layer '%s' - skipping."
-msgstr ""
-
-#: activate/dev_manager.c:1782
-#, c-format
-msgid "Couldn't deactivate device %s"
+#: activate/dev_manager.c:1013 activate/dev_manager.c:1133
+msgid "Lost dependency tree root node"
 msgstr ""
 
-#: activate/dev_manager.c:1898
+#: activate/dev_manager.c:1055
 #, c-format
-msgid "Found existing layer '%s'"
+msgid "Failed to create symlinks for %s."
 msgstr ""
 
-#: activate/dev_manager.c:2078
+#: activate/dev_manager.c:1060
 #, c-format
-msgid "Can't expand LV: %s target support missing from kernel?"
+msgid "_tree_action: Action %u not supported."
 msgstr ""
 
-#: activate/dev_manager.c:2090
-msgid "Can't expand LV: Mirror support missing from tools?"
+#: activate/dev_manager.c:1119
+msgid "partial dtree creation failed"
 msgstr ""
 
-#: activate/dev_manager.c:2097
-msgid "Can't expand LV: Mirror support missing from kernel?"
-msgstr ""
-
-#: activate/dev_manager.c:2105
-msgid "Can't expand LV: Snapshot support missing from tools?"
-msgstr ""
-
-#: activate/dev_manager.c:2112
-msgid "Can't expand LV: Snapshot support missing from kernel?"
-msgstr ""
-
-#: activate/dev_manager.c:2140
+#: activate/dev_manager.c:1124
 #, c-format
-msgid "Found active lv %s%s"
+msgid "Failed to add device %s (%u:%u) to dtree"
 msgstr ""
 
-#: activate/fs.c:40 activate/fs.c:63
+#: activate/fs.c:35 activate/fs.c:58
 msgid "Couldn't construct name of volume group directory."
 msgstr ""
 
-#: activate/fs.c:48
+#: activate/fs.c:43
 #, c-format
 msgid "Creating directory %s"
 msgstr ""
 
-#: activate/fs.c:50 activate/fs.c:85 activate/fs.c:105 activate/fs.c:158
-#: activate/fs.c:171 activate/fs.c:178 activate/fs.c:213
-#: commands/toolcontext.c:342 commands/toolcontext.c:799 config/config.c:155
-#: config/config.c:204 config/config.c:220 config/config.c:285
-#: config/config.c:382 device/dev-cache.c:172 device/dev-cache.c:176
-#: device/dev-cache.c:358 device/dev-cache.c:381 device/dev-cache.c:388
-#: device/dev-cache.c:581 device/dev-cache.c:583 device/dev-io.c:131
-#: device/dev-io.c:231 device/dev-io.c:249 device/dev-io.c:254
-#: device/dev-io.c:256 device/dev-io.c:262 device/dev-io.c:386
-#: device/dev-io.c:388 device/dev-io.c:451 filters/filter-persistent.c:186
-#: filters/filter-sysfs.c:43 filters/filter-sysfs.c:155
-#: filters/filter-sysfs.c:179 filters/filter-sysfs.c:222 filters/filter.c:153
-#: format_text/archive.c:216 format_text/archive.c:225
-#: format_text/format-text.c:656 format_text/format-text.c:670
-#: format_text/format-text.c:676 format_text/format-text.c:701
-#: format_text/format-text.c:763 format_text/format-text.c:768
-#: format_text/format-text.c:793 format_text/format-text.c:818
+#: activate/fs.c:45 activate/fs.c:80 activate/fs.c:100 activate/fs.c:153
+#: activate/fs.c:166 activate/fs.c:173 activate/fs.c:208
+#: commands/toolcontext.c:342 commands/toolcontext.c:820 config/config.c:209
+#: config/config.c:247 config/config.c:262 config/config.c:328
+#: config/config.c:428 config/config.c:452 device/dev-cache.c:208
+#: device/dev-cache.c:212 device/dev-cache.c:394 device/dev-cache.c:417
+#: device/dev-cache.c:424 device/dev-cache.c:681 device/dev-cache.c:683
+#: device/dev-io.c:131 device/dev-io.c:231 device/dev-io.c:249
+#: device/dev-io.c:254 device/dev-io.c:256 device/dev-io.c:262
+#: device/dev-io.c:396 device/dev-io.c:398 device/dev-io.c:481
+#: filters/filter-persistent.c:203 filters/filter-persistent.c:207
+#: filters/filter-persistent.c:230 filters/filter-persistent.c:243
+#: filters/filter-sysfs.c:42 filters/filter-sysfs.c:58
+#: filters/filter-sysfs.c:156 filters/filter-sysfs.c:163
+#: filters/filter-sysfs.c:182 filters/filter-sysfs.c:225 filters/filter.c:164
+#: filters/filter.c:221 filters/filter.c:232 filters/filter.c:240
+#: filters/filter.c:253 format_text/archive.c:214 format_text/archive.c:223
+#: format_text/archive.c:253 format_text/archive.c:260
+#: format_text/archive.c:265 format_text/format-text.c:873
+#: format_text/format-text.c:875 format_text/format-text.c:884
+#: format_text/format-text.c:889 format_text/format-text.c:891
+#: format_text/format-text.c:896 format_text/format-text.c:921
+#: format_text/format-text.c:983 format_text/format-text.c:988
+#: format_text/format-text.c:1013 format_text/format-text.c:1040
 #: locking/file_locking.c:61 locking/file_locking.c:69
 #: locking/file_locking.c:72 locking/file_locking.c:105
-#: locking/file_locking.c:171 locking/file_locking.c:187
-#: locking/file_locking.c:294 locking/file_locking.c:299 locking/locking.c:44
-#: locking/locking.c:49 locking/locking.c:65 locking/locking.c:203
-#: log/log.c:64 lvmcmdline.c:1347 misc/lvm-file.c:47 misc/lvm-file.c:96
-#: misc/lvm-file.c:106 misc/lvm-file.c:156 misc/lvm-file.c:169
-#: misc/lvm-file.c:198 misc/lvm-file.c:207 misc/lvm-file.c:235
-#: misc/lvm-file.c:240 mm/memlock.c:98 mm/memlock.c:106 mm/memlock.c:117
-#: toollib.c:992 uuid/uuid.c:84 uuid/uuid.c:89
+#: locking/file_locking.c:167 locking/file_locking.c:171
+#: locking/file_locking.c:187 locking/file_locking.c:296
+#: locking/file_locking.c:301 locking/locking.c:45 locking/locking.c:50
+#: locking/locking.c:66 locking/locking.c:221 log/log.c:69 lvmcmdline.c:1092
+#: lvmcmdline.c:1130 misc/lvm-exec.c:42 misc/lvm-file.c:47 misc/lvm-file.c:70
+#: misc/lvm-file.c:97 misc/lvm-file.c:107 misc/lvm-file.c:157
+#: misc/lvm-file.c:170 misc/lvm-file.c:199 misc/lvm-file.c:208
+#: misc/lvm-file.c:236 misc/lvm-file.c:241 misc/lvm-file.c:244
+#: misc/lvm-file.c:289 misc/lvm-file.c:297 misc/timestamp.c:47 mm/memlock.c:97
+#: mm/memlock.c:105 mm/memlock.c:116 uuid/uuid.c:83 uuid/uuid.c:88
 #, c-format
 msgid "%s: %s failed: %s"
 msgstr ""
 
-#: activate/fs.c:69
+#: activate/fs.c:64
 #, c-format
 msgid "Removing directory %s"
 msgstr ""
 
-#: activate/fs.c:96
+#: activate/fs.c:91
 #, c-format
 msgid "Couldn't create path for %s"
 msgstr ""
 
-#: activate/fs.c:119
+#: activate/fs.c:98 activate/fs.c:151 activate/fs.c:164
+#, c-format
+msgid "Removing %s"
+msgstr ""
+
+#: activate/fs.c:114
 #, c-format
 msgid "Couldn't create path for volume group dir %s"
 msgstr ""
 
-#: activate/fs.c:126
+#: activate/fs.c:121
 #, c-format
 msgid "Couldn't create source pathname for logical volume link %s"
 msgstr ""
 
-#: activate/fs.c:133
+#: activate/fs.c:128
 #, c-format
 msgid "Couldn't create destination pathname for logical volume link for %s"
 msgstr ""
 
-#: activate/fs.c:140
+#: activate/fs.c:135
 #, c-format
 msgid "Couldn't create pathname for LVM1 group file for %s"
 msgstr ""
 
-#: activate/fs.c:151
+#: activate/fs.c:146
 #, c-format
 msgid "Non-LVM1 character device found at %s"
 msgstr ""
 
-#: activate/fs.c:164
+#: activate/fs.c:159
 #, c-format
 msgid "Symbolic link %s not created: file exists"
 msgstr ""
 
-#: activate/fs.c:176
+#: activate/fs.c:171
 #, c-format
 msgid "Linking %s -> %s"
 msgstr ""
 
-#: activate/fs.c:200
+#: activate/fs.c:195
 msgid "Couldn't determine link pathname."
 msgstr ""
 
-#: activate/fs.c:207
+#: activate/fs.c:202
 #, c-format
 msgid "%s not symbolic link - not removing"
 msgstr ""
 
-#: activate/fs.c:211
+#: activate/fs.c:206
 #, c-format
 msgid "Removing link %s"
 msgstr ""
 
-#: activate/fs.c:287
+#: activate/fs.c:282
 msgid "No space to stack fs operation"
 msgstr ""
 
@@ -809,81 +726,165 @@
 msgid "Couldn't create backup object."
 msgstr ""
 
-#: cache/lvmcache.c:57 cache/lvmcache.c:202 cache/lvmcache.c:464
+#: cache/lvmcache.c:56 cache/lvmcache.c:235 cache/lvmcache.c:740
 msgid "Internal cache initialisation failed"
 msgstr ""
 
-#: cache/lvmcache.c:62
+#: cache/lvmcache.c:61
 #, c-format
 msgid "Cache locking failure for %s"
 msgstr ""
 
-#: cache/lvmcache.c:212 toollib.c:492
+#: cache/lvmcache.c:127
+msgid "device_list element allocation failed"
+msgstr ""
+
+#: cache/lvmcache.c:245 toollib.c:638
 msgid "dev_iter creation failed"
 msgstr ""
 
-#: cache/lvmcache.c:245
-msgid "vgnames list allocation failed"
+#: cache/lvmcache.c:278
+msgid "vgids list allocation failed"
 msgstr ""
 
-#: cache/lvmcache.c:252 toollib.c:150 toollib.c:195 toollib.c:203
-#: toollib.c:215 toollib.c:275 toollib.c:406 toollib.c:426 toollib.c:552
+#: cache/lvmcache.c:285 cache/lvmcache.c:308 cache/lvmcache.c:334
+#: toollib.c:271 toollib.c:306 toollib.c:314 toollib.c:326 toollib.c:405
+#: toollib.c:547 toollib.c:561 toollib.c:698
 msgid "strlist allocation failed"
 msgstr ""
 
-#: cache/lvmcache.c:346
+#: cache/lvmcache.c:301
+msgid "vgnames list allocation failed"
+msgstr ""
+
+#: cache/lvmcache.c:324
+msgid "pvids list allocation failed"
+msgstr ""
+
+#: cache/lvmcache.c:395
+#, c-format
+msgid "vg hash re-insertion failed: %s"
+msgstr ""
+
+#: cache/lvmcache.c:440
 #, c-format
 msgid "_lvmcache_update: pvid insertion failed: %s"
 msgstr ""
 
-#: cache/lvmcache.c:367
+#: cache/lvmcache.c:456
+#, c-format
+msgid "lvmcache: %s: clearing VGID"
+msgstr ""
+
+#: cache/lvmcache.c:463
 #, c-format
 msgid "_lvmcache_update: vgid hash insertion failed: %s"
 msgstr ""
 
-#: cache/lvmcache.c:395
+#: cache/lvmcache.c:468
+#, c-format
+msgid "lvmcache: %s: setting %s VGID to %s"
+msgstr ""
+
+#: cache/lvmcache.c:502
+#, c-format
+msgid ""
+"WARNING: Duplicate VG name %s: Existing %s takes precedence over exported %s"
+msgstr ""
+
+#: cache/lvmcache.c:508
+#, c-format
+msgid "WARNING: Duplicate VG name %s: %s takes precedence over exported %s"
+msgstr ""
+
+#: cache/lvmcache.c:516
+#, c-format
+msgid ""
+"WARNING: Duplicate VG name %s: Existing %s (created here) takes precedence "
+"over %s"
+msgstr ""
+
+#: cache/lvmcache.c:521
+#, c-format
+msgid ""
+"WARNING: Duplicate VG name %s: %s (with creation_host) takes precedence over "
+"%s"
+msgstr ""
+
+#: cache/lvmcache.c:529
+#, c-format
+msgid ""
+"WARNING: Duplicate VG name %s: %s (created here) takes precedence over %s"
+msgstr ""
+
+#: cache/lvmcache.c:547
+#, c-format
+msgid "cache_update: vg hash insertion failed: %s"
+msgstr ""
+
+#: cache/lvmcache.c:619
 msgid "lvmcache_update_vgname: list alloc failed"
 msgstr ""
 
-#: cache/lvmcache.c:401
+#: cache/lvmcache.c:625
 #, c-format
 msgid "cache vgname alloc failed for %s"
 msgstr ""
 
-#: cache/lvmcache.c:406
+#: cache/lvmcache.c:652
 #, c-format
-msgid "cache_update: vg hash insertion failed: %s"
+msgid "lvmcache: %s: now %s%s%s%s%s"
+msgstr ""
+
+#: cache/lvmcache.c:668
+#, c-format
+msgid "lvmcache: %s: VG %s %s exported"
+msgstr ""
+
+#: cache/lvmcache.c:685
+#, c-format
+msgid "cache creation host alloc failed for %s"
 msgstr ""
 
-#: cache/lvmcache.c:425
+#: cache/lvmcache.c:690
 #, c-format
-msgid "lvmcache: %s now %s%s"
+msgid "lvmcache: %s: VG %s: Set creation host to %s."
 msgstr ""
 
-#: cache/lvmcache.c:478
+#: cache/lvmcache.c:754
 msgid "lvmcache_info allocation failed"
 msgstr ""
 
-#: cache/lvmcache.c:493
+#: cache/lvmcache.c:769
 #, c-format
 msgid "Ignoring duplicate PV %s on %s - using md %s"
 msgstr ""
 
-#: cache/lvmcache.c:500
+#: cache/lvmcache.c:776
+#, c-format
+msgid "Ignoring duplicate PV %s on %s - using dm %s"
+msgstr ""
+
+#: cache/lvmcache.c:783
 #, c-format
 msgid "Duplicate PV %s on %s - using md %s"
 msgstr ""
 
-#: cache/lvmcache.c:505
+#: cache/lvmcache.c:789
+#, c-format
+msgid "Duplicate PV %s on %s - using dm %s"
+msgstr ""
+
+#: cache/lvmcache.c:798
 #, c-format
 msgid "Found duplicate PV %s: using %s not %s"
 msgstr ""
 
-#: cache/lvmcache.c:574
+#: cache/lvmcache.c:872
 msgid "Wiping internal VG cache"
 msgstr ""
 
-#: commands/toolcontext.c:73
+#: commands/toolcontext.c:70
 msgid "LVM_SYSTEM_DIR environment variable is too long."
 msgstr ""
 
@@ -906,7 +907,7 @@
 msgid "Warning: proc dir %s not found - some checks will be bypassed"
 msgstr ""
 
-#: commands/toolcontext.c:207 lvmcmdline.c:694
+#: commands/toolcontext.c:207 lvmcmdline.c:723
 msgid "Invalid units specification"
 msgstr ""
 
@@ -960,342 +961,380 @@
 msgid "Failed to create config tree"
 msgstr ""
 
-#: commands/toolcontext.c:475
+#: commands/toolcontext.c:473
 msgid "Failed to add /dev to internal device cache"
 msgstr ""
 
-#: commands/toolcontext.c:479
+#: commands/toolcontext.c:477
 msgid "device/scan not in config file: Defaulting to /dev"
 msgstr ""
 
-#: commands/toolcontext.c:486
+#: commands/toolcontext.c:484
 msgid "Invalid string in config file: devices/scan"
 msgstr ""
 
-#: commands/toolcontext.c:492 format_text/format-text.c:1692
+#: commands/toolcontext.c:490 format_text/format-text.c:1980
 #, c-format
 msgid "Failed to add %s to internal device cache"
 msgstr ""
 
-#: commands/toolcontext.c:503
+#: commands/toolcontext.c:501
 msgid "Invalid string in config file: devices/loopfiles"
 msgstr ""
 
-#: commands/toolcontext.c:509
+#: commands/toolcontext.c:507
 #, c-format
 msgid "Failed to add loopfile %s to internal device cache"
 msgstr ""
 
-#: commands/toolcontext.c:548
+#: commands/toolcontext.c:546
 msgid "devices/filter not found in config file: no regex filter installed"
 msgstr ""
 
-#: commands/toolcontext.c:552
+#: commands/toolcontext.c:550
 msgid "Failed to create regex device filter"
 msgstr ""
 
-#: commands/toolcontext.c:559
+#: commands/toolcontext.c:557
 msgid "Failed to create lvm type filter"
 msgstr ""
 
-#: commands/toolcontext.c:590
-#, c-format
-msgid "Persistent cache filename too long ('%s/.cache')."
+#: commands/toolcontext.c:602 commands/toolcontext.c:610
+msgid "Persistent cache filename too long."
 msgstr ""
 
-#: commands/toolcontext.c:598
+#: commands/toolcontext.c:615
 msgid "Failed to create persistent device filter"
 msgstr ""
 
-#: commands/toolcontext.c:612
+#: commands/toolcontext.c:634
 #, c-format
 msgid "Failed to load existing device cache from %s"
 msgstr ""
 
-#: commands/toolcontext.c:656
+#: commands/toolcontext.c:679
 msgid "Invalid string in config file: global/format_libraries"
 msgstr ""
 
-#: commands/toolcontext.c:667
+#: commands/toolcontext.c:690
 #, c-format
 msgid "Shared library %s does not contain format functions"
 msgstr ""
 
-#: commands/toolcontext.c:699
+#: commands/toolcontext.c:722
 #, c-format
 msgid "_init_formats: Default format (%s) not found"
 msgstr ""
 
-#: commands/toolcontext.c:752
+#: commands/toolcontext.c:775
 msgid "Invalid string in config file: global/segment_libraries"
 msgstr ""
 
-#: commands/toolcontext.c:763
+#: commands/toolcontext.c:786
 #, c-format
 msgid "Shared library %s does not contain segment type functions"
 msgstr ""
 
-#: commands/toolcontext.c:777
+#: commands/toolcontext.c:801
 #, c-format
 msgid "Duplicate segment type %s: unloading shared library %s"
 msgstr ""
 
-#: commands/toolcontext.c:804
-msgid "_init_hostname: pool_strdup failed"
+#: commands/toolcontext.c:825
+msgid "_init_hostname: dm_pool_strdup failed"
 msgstr ""
 
-#: commands/toolcontext.c:809
-msgid "_init_hostname: pool_strdup kernel_vsn failed"
+#: commands/toolcontext.c:830
+msgid "_init_hostname: dm_pool_strdup kernel_vsn failed"
 msgstr ""
 
-#: commands/toolcontext.c:823
+#: commands/toolcontext.c:844
 msgid "WARNING: Metadata changes will NOT be backed up"
 msgstr ""
 
-#: commands/toolcontext.c:843
+#: commands/toolcontext.c:864
 #, c-format
 msgid "Couldn't create default archive path '%s/%s'."
 msgstr ""
 
-#: commands/toolcontext.c:852 commands/toolcontext.c:872
+#: commands/toolcontext.c:873 commands/toolcontext.c:893
 msgid "backup_init failed."
 msgstr ""
 
-#: commands/toolcontext.c:864
+#: commands/toolcontext.c:885
 #, c-format
 msgid "Couldn't create default backup path '%s/%s'."
 msgstr ""
 
-#: commands/toolcontext.c:889
+#: commands/toolcontext.c:911
 msgid "setlocale failed"
 msgstr ""
 
-#: commands/toolcontext.c:898
+#: commands/toolcontext.c:920
 msgid "Failed to allocate command context"
 msgstr ""
 
-#: commands/toolcontext.c:916
+#: commands/toolcontext.c:940
 msgid ""
 "Failed to create LVM2 system dir for metadata backups, config files and "
 "internal cache."
 msgstr ""
 
-#: commands/toolcontext.c:918
+#: commands/toolcontext.c:942
 msgid ""
 "Set environment variable LVM_SYSTEM_DIR to alternative location or empty "
 "string."
 msgstr ""
 
-#: commands/toolcontext.c:924
+#: commands/toolcontext.c:948
 msgid "Library memory pool creation failed"
 msgstr ""
 
-#: commands/toolcontext.c:955
+#: commands/toolcontext.c:979
 msgid "Command memory pool creation failed"
 msgstr ""
 
-#: commands/toolcontext.c:1018
+#: commands/toolcontext.c:1042
 msgid "Reloading config files"
 msgstr ""
 
-#: config/config.c:165
-#, c-format
-msgid "Read from %s failed"
+#: config/config.c:111
+msgid "Failed to allocate config pool."
 msgstr ""
 
-#: config/config.c:171
-#, c-format
-msgid "Circular read from %s failed"
+#: config/config.c:116
+msgid "Failed to allocate config tree."
+msgstr ""
+
+#: config/config.c:165
+msgid "Failed to allocate config tree parser."
 msgstr ""
 
-#: config/config.c:181
+#: config/config.c:228
 #, c-format
 msgid "%s: Checksum error"
 msgstr ""
 
-#: config/config.c:226
+#: config/config.c:268
 #, c-format
 msgid "%s is not a regular file"
 msgstr ""
 
-#: config/config.c:234
+#: config/config.c:276
 #, c-format
 msgid "%s is empty"
 msgstr ""
 
-#: config/config.c:281
+#: config/config.c:324
 #, c-format
 msgid "Config file %s has disappeared!"
 msgstr ""
 
-#: config/config.c:286
+#: config/config.c:329
 msgid "Failed to reload configuration files"
 msgstr ""
 
-#: config/config.c:291
+#: config/config.c:334
 #, c-format
 msgid "Configuration file %s is not a regular file"
 msgstr ""
 
-#: config/config.c:301
+#: config/config.c:344
 #, c-format
 msgid "Detected config file change to %s"
 msgstr ""
 
-#: config/config.c:325
+#: config/config.c:368
 #, c-format
 msgid "_write_value: Unknown value type: %d"
 msgstr ""
 
-#: config/config.c:386
+#: config/config.c:432
 #, c-format
 msgid "Dumping configuration to %s"
 msgstr ""
 
-#: config/config.c:388
-msgid "Failure while writing configuration"
+#: config/config.c:435 config/config.c:441
+#, c-format
+msgid "Failure while writing to %s"
+msgstr ""
+
+#: config/config.c:445
+#, c-format
+msgid "Configuration node %s not found"
+msgstr ""
+
+#: config/config.c:494 config/config.c:497 config/config.c:510
+#: config/config.c:512 config/config.c:527 config/config.c:541
+#: config/config.c:543 config/config.c:572 config/config.c:578
+#: config/config.c:590
+#, c-format
+msgid "Parse error at byte %td (line %d): unexpected token"
 msgstr ""
 
-#: config/config.c:433 config/config.c:436 config/config.c:449
-#: config/config.c:451 config/config.c:466 config/config.c:480
-#: config/config.c:482 config/config.c:511 config/config.c:517
-#: config/config.c:529
+#: config/config.c:594
 #, c-format
-msgid "Parse error at line %d: unexpected token"
+msgid "Parse error at byte %td (line %d): expected a value"
 msgstr ""
 
-#: config/config.c:533
+#: config/config.c:810
 #, c-format
-msgid "Parse error at line %d: expected a value"
+msgid "WARNING: Ignoring duplicate config node: %s (seeking %s)"
 msgstr ""
 
-#: config/config.c:758
+#: config/config.c:858
 #, c-format
 msgid "Setting %s to %s"
 msgstr ""
 
-#: config/config.c:763
+#: config/config.c:863
 #, c-format
 msgid "%s not found in config: defaulting to %s"
 msgstr ""
 
-#: config/config.c:773
+#: config/config.c:881
 #, c-format
-msgid "Setting %s to %d"
+msgid "Setting %s to %ld"
 msgstr ""
 
-#: config/config.c:777
+#: config/config.c:885
 #, c-format
-msgid "%s not found in config: defaulting to %d"
+msgid "%s not found in config: defaulting to %ld"
 msgstr ""
 
-#: config/config.c:788
+#: config/config.c:903
 #, c-format
 msgid "Setting %s to %f"
 msgstr ""
 
-#: config/config.c:792
+#: config/config.c:907
 #, c-format
 msgid "%s not found in config: defaulting to %f"
 msgstr ""
 
-#: device/dev-cache.c:65 device/dev-cache.c:82 device/dev-cache.c:119
+#: device/dev-cache.c:64 device/dev-cache.c:81 device/dev-cache.c:118
 msgid "struct device allocation failed"
 msgstr ""
 
-#: device/dev-cache.c:69 device/dev-cache.c:86
+#: device/dev-cache.c:68 device/dev-cache.c:85
 msgid "struct str_list allocation failed"
 msgstr ""
 
-#: device/dev-cache.c:74 device/dev-cache.c:91 device/dev-cache.c:96
+#: device/dev-cache.c:73 device/dev-cache.c:90 device/dev-cache.c:95
 msgid "filename strdup failed"
 msgstr ""
 
-#: device/dev-cache.c:211
+#: device/dev-cache.c:142
+#, c-format
+msgid "%s: New preferred name"
+msgstr ""
+
+#: device/dev-cache.c:247
 #, c-format
 msgid "%s: Already in device cache"
 msgstr ""
 
-#: device/dev-cache.c:224
+#: device/dev-cache.c:260
 #, c-format
 msgid "%s: Aliased to %s in device cache%s"
 msgstr ""
 
-#: device/dev-cache.c:228
+#: device/dev-cache.c:264
 #, c-format
 msgid "%s: Added to device cache"
 msgstr ""
 
-#: device/dev-cache.c:271
+#: device/dev-cache.c:307
 msgid "Couldn't insert device into binary tree."
 msgstr ""
 
-#: device/dev-cache.c:278
+#: device/dev-cache.c:314
 msgid "Couldn't add alias to dev cache."
 msgstr ""
 
-#: device/dev-cache.c:283
+#: device/dev-cache.c:319
 msgid "Couldn't add name to hash in dev cache."
 msgstr ""
 
-#: device/dev-cache.c:363
+#: device/dev-cache.c:399
 #, c-format
 msgid "%s: Not a regular file"
 msgstr ""
 
-#: device/dev-cache.c:393
+#: device/dev-cache.c:429
 #, c-format
 msgid "%s: Symbolic link to directory"
 msgstr ""
 
-#: device/dev-cache.c:402
+#: device/dev-cache.c:438
 #, c-format
 msgid "%s: Not a block device"
 msgstr ""
 
-#: device/dev-cache.c:465
+#: device/dev-cache.c:496
+msgid ""
+"devices/preferred_names not found in config file: using built-in preferences"
+msgstr ""
+
+#: device/dev-cache.c:503
+msgid "preferred_names patterns must be enclosed in quotes"
+msgstr ""
+
+#: device/dev-cache.c:514
+msgid "Failed to allocate preferred device name pattern list."
+msgstr ""
+
+#: device/dev-cache.c:521
+msgid "Failed to allocate a preferred device name pattern."
+msgstr ""
+
+#: device/dev-cache.c:529
+msgid "Preferred device name pattern matcher creation failed."
+msgstr ""
+
+#: device/dev-cache.c:559
 msgid "Couldn't create binary tree for dev-cache."
 msgstr ""
 
-#: device/dev-cache.c:482
+#: device/dev-cache.c:579
 #, c-format
 msgid "Device '%s' has been left open."
 msgstr ""
 
-#: device/dev-cache.c:517 device/dev-cache.c:543
+#: device/dev-cache.c:617 device/dev-cache.c:643
 #, c-format
 msgid "Ignoring %s: %s"
 msgstr ""
 
-#: device/dev-cache.c:523
+#: device/dev-cache.c:623
 #, c-format
 msgid "Ignoring %s: Not a directory"
 msgstr ""
 
-#: device/dev-cache.c:528
+#: device/dev-cache.c:628
 msgid "dir_list allocation failed"
 msgstr ""
 
-#: device/dev-cache.c:549
+#: device/dev-cache.c:649
 #, c-format
 msgid "Ignoring %s: Not a regular file"
 msgstr ""
 
-#: device/dev-cache.c:554
+#: device/dev-cache.c:654
 msgid "dir_list allocation failed for file"
 msgstr ""
 
-#: device/dev-cache.c:586 device/dev-cache.c:590
+#: device/dev-cache.c:686 device/dev-cache.c:690
 #, c-format
 msgid "Path %s no longer valid for device(%d,%d)"
 msgstr ""
 
-#: device/dev-cache.c:607
+#: device/dev-cache.c:707
 #, c-format
 msgid "Aborting - please provide new pathname for what used to be %s"
 msgstr ""
 
-#: device/dev-cache.c:647
+#: device/dev-cache.c:747
 msgid "dev_iter allocation failed"
 msgstr ""
 
@@ -1306,17 +1345,17 @@
 
 #: device/dev-io.c:79
 #, c-format
-msgid "Read size too large: %llu"
+msgid "Read size too large: %lu"
 msgstr ""
 
 #: device/dev-io.c:84
 #, c-format
-msgid "%s: lseek %llu failed: %s"
+msgid "%s: lseek %lu failed: %s"
 msgstr ""
 
 #: device/dev-io.c:98
 #, c-format
-msgid "%s: %s failed after %llu of %llu at %llu: %s"
+msgid "%s: %s failed after %lu of %lu at %lu: %s"
 msgstr ""
 
 #: device/dev-io.c:134
@@ -1330,432 +1369,448 @@
 
 #: device/dev-io.c:238 device/dev-io.c:264
 #, c-format
-msgid "%s: size is %llu sectors"
+msgid "%s: size is %lu sectors"
 msgstr ""
 
-#: device/dev-io.c:333
+#: device/dev-io.c:343
 #, c-format
 msgid "WARNING: %s already opened read-only"
 msgstr ""
 
-#: device/dev-io.c:342
+#: device/dev-io.c:352
 #, c-format
 msgid "WARNING: dev_open(%s) called while suspended"
 msgstr ""
 
-#: device/dev-io.c:354
+#: device/dev-io.c:364
 #, c-format
 msgid "%s: stat failed: Has device name changed?"
 msgstr ""
 
-#: device/dev-io.c:380
+#: device/dev-io.c:390
 #, c-format
 msgid "%s: Not using O_DIRECT"
 msgstr ""
 
-#: device/dev-io.c:407
+#: device/dev-io.c:422
 #, c-format
 msgid "%s: fstat failed: Has device name changed?"
 msgstr ""
 
-#: device/dev-io.c:423
+#: device/dev-io.c:437
 #, c-format
-msgid "Opened %s %s%s"
+msgid "Opened %s %s%s%s"
 msgstr ""
 
-#: device/dev-io.c:456
+#: device/dev-io.c:486
 #, c-format
 msgid "Closed %s"
 msgstr ""
 
-#: device/dev-io.c:469
+#: device/dev-io.c:501
 #, c-format
 msgid "Attempt to close device '%s' which is not open."
 msgstr ""
 
-#: device/dev-io.c:579
-msgid "Wiping %s at %llu length %zu"
+#: device/dev-io.c:515
+#, c-format
+msgid "%s: Immediate close attempt while still referenced"
+msgstr ""
+
+#: device/dev-io.c:576
+#, c-format
+msgid "Read from %s failed"
+msgstr ""
+
+#: device/dev-io.c:588
+#, c-format
+msgid "Circular read from %s failed"
+msgstr ""
+
+#: device/dev-io.c:648
+#, c-format
+msgid "Wiping %s at %lu length %zu"
 msgstr ""
 
-#: device/dev-io.c:582
-msgid "Wiping %s at sector %llu length %zu sectors"
+#: device/dev-io.c:651
+#, c-format
+msgid "Wiping %s at sector %lu length %zu sectors"
 msgstr ""
 
-#: display/display.c:130
+#: display/display.c:145
 #, c-format
 msgid "Unrecognised allocation policy %s"
 msgstr ""
 
-#: display/display.c:155
+#: display/display.c:172
 msgid "no memory for size display buffer"
 msgstr ""
 
-#: display/display.c:215
+#: display/display.c:247
 #, c-format
-msgid "%s:%s:%llu:-1:%u:%u:-1:%u:%u:%u:%u:%s"
+msgid "%s:%s:%lu:-1:%u:%u:-1:%u:%u:%u:%u:%s"
 msgstr ""
 
-#: display/display.c:246
+#: display/display.c:278
 #, c-format
 msgid "--- %sPhysical volume ---"
 msgstr ""
 
-#: display/display.c:247
+#: display/display.c:279
 #, c-format
 msgid "PV Name               %s"
 msgstr ""
 
-#: display/display.c:248
+#: display/display.c:280
 #, c-format
 msgid "VG Name               %s%s"
 msgstr ""
 
-#: display/display.c:258
+#: display/display.c:290
 #, c-format
 msgid "PV Size               %s / not usable %s"
 msgstr ""
 
-#: display/display.c:265
+#: display/display.c:296
 #, c-format
 msgid "PV Size               %s"
 msgstr ""
 
-#: display/display.c:273
+#: display/display.c:304
 #, c-format
 msgid "Allocatable           yes %s"
 msgstr ""
 
-#: display/display.c:276
+#: display/display.c:307
 msgid "Allocatable           NO"
 msgstr ""
 
-#: display/display.c:281
+#: display/display.c:312
 #, c-format
 msgid "PE Size (KByte)       %u"
 msgstr ""
 
-#: display/display.c:282 display/display.c:563
+#: display/display.c:313 display/display.c:592
 #, c-format
 msgid "Total PE              %u"
 msgstr ""
 
-#: display/display.c:283
+#: display/display.c:314
 #, c-format
 msgid "Free PE               %u"
 msgstr ""
 
-#: display/display.c:284
+#: display/display.c:315
 #, c-format
 msgid "Allocated PE          %u"
 msgstr ""
 
-#: display/display.c:285 display/display.c:306
+#: display/display.c:316 display/display.c:339
 #, c-format
 msgid "PV UUID               %s"
 msgstr ""
 
-#: display/display.c:286 display/display.c:312 display/display.c:445
-#: display/display.c:496 display/display.c:582 format_text/archive.c:311
-#: lvmcmdline.c:729 mirror/mirrored.c:66 striped/striped.c:51
+#: display/display.c:317 display/display.c:345 display/display.c:476
+#: display/display.c:527 display/display.c:610 format_text/archive.c:315
+#: lvmcmdline.c:769 mirror/mirrored.c:73 striped/striped.c:49
 msgid " "
 msgstr ""
 
-#: display/display.c:304
+#: display/display.c:337
 #, c-format
 msgid "PV Name               %s     "
 msgstr ""
 
-#: display/display.c:307
+#: display/display.c:340
 #, c-format
 msgid "PV Status             %sallocatable"
 msgstr ""
 
-#: display/display.c:309
+#: display/display.c:342
 #, c-format
 msgid "Total PE / Free PE    %u / %u"
 msgstr ""
 
-#: display/display.c:322
+#: display/display.c:355
 #, c-format
-msgid "%s%s/%s:%s:%d:%d:-1:%d:%llu:%d:-1:%d:%d:%d:%d"
+msgid "%s%s/%s:%s:%d:%d:-1:%d:%lu:%d:-1:%d:%d:%d:%d"
 msgstr ""
 
-#: display/display.c:352
+#: display/display.c:385
 msgid "--- Logical volume ---"
 msgstr ""
 
-#: display/display.c:354
+#: display/display.c:387
 #, c-format
 msgid "LV Name                %s%s/%s"
 msgstr ""
 
-#: display/display.c:356
+#: display/display.c:389
 #, c-format
 msgid "VG Name                %s"
 msgstr ""
 
-#: display/display.c:358
+#: display/display.c:391
 #, c-format
 msgid "LV UUID                %s"
 msgstr ""
 
-#: display/display.c:360
+#: display/display.c:393
 #, c-format
 msgid "LV Write Access        %s"
 msgstr ""
 
-#: display/display.c:364
+#: display/display.c:397
 msgid "LV snapshot status     source of"
 msgstr ""
 
-#: display/display.c:373
+#: display/display.c:406
 #, c-format
 msgid "                       %s%s/%s [%s]"
 msgstr ""
 
-#: display/display.c:386
+#: display/display.c:419
 #, c-format
 msgid "LV snapshot status     %s destination for %s%s/%s"
 msgstr ""
 
-#: display/display.c:393
+#: display/display.c:426
 msgid "LV Status              suspended"
 msgstr ""
 
-#: display/display.c:395
+#: display/display.c:428
 #, c-format
 msgid "LV Status              %savailable"
 msgstr ""
 
-#: display/display.c:403
+#: display/display.c:436
 #, c-format
 msgid "# open                 %u"
 msgstr ""
 
-#: display/display.c:405
+#: display/display.c:438
 #, c-format
 msgid "LV Size                %s"
 msgstr ""
 
-#: display/display.c:410
+#: display/display.c:442
 #, c-format
 msgid "Current LE             %u"
 msgstr ""
 
-#: display/display.c:414
+#: display/display.c:446
 #, c-format
 msgid "COW-table size         %s"
 msgstr ""
 
-#: display/display.c:416
+#: display/display.c:448
 #, c-format
 msgid "COW-table LE           %u"
 msgstr ""
 
-#: display/display.c:419
+#: display/display.c:451
 #, c-format
 msgid "Allocated to snapshot  %.2f%% "
 msgstr ""
 
-#: display/display.c:421
+#: display/display.c:453
 #, c-format
 msgid "Snapshot chunk size    %s"
 msgstr ""
 
-#: display/display.c:426
+#: display/display.c:457
 #, c-format
 msgid "Segments               %u"
 msgstr ""
 
-#: display/display.c:432
+#: display/display.c:463
 #, c-format
 msgid "Allocation             %s"
 msgstr ""
 
-#: display/display.c:433
+#: display/display.c:464
 #, c-format
 msgid "Read ahead sectors     %u"
 msgstr ""
 
-#: display/display.c:437
+#: display/display.c:468
 #, c-format
 msgid "Persistent major       %d"
 msgstr ""
 
-#: display/display.c:438
+#: display/display.c:469
 #, c-format
 msgid "Persistent minor       %d"
 msgstr ""
 
-#: display/display.c:442
+#: display/display.c:473
 #, c-format
 msgid "Block device           %d:%d"
 msgstr ""
 
-#: display/display.c:455
+#: display/display.c:486
 #, c-format
 msgid "%sPhysical volume\t%s"
 msgstr ""
 
-#: display/display.c:461
+#: display/display.c:492
 #, c-format
 msgid "%sPhysical extents\t%d to %d"
 msgstr ""
 
-#: display/display.c:466
+#: display/display.c:497
 #, c-format
 msgid "%sLogical volume\t%s"
 msgstr ""
 
-#: display/display.c:471
+#: display/display.c:502
 #, c-format
 msgid "%sLogical extents\t%d to %d"
 msgstr ""
 
-#: display/display.c:476
+#: display/display.c:507
 #, c-format
 msgid "%sUnassigned area"
 msgstr ""
 
-#: display/display.c:484
+#: display/display.c:515
 msgid "--- Segments ---"
 msgstr ""
 
-#: display/display.c:487
+#: display/display.c:518
 #, c-format
 msgid "Logical extent %u to %u:"
 msgstr ""
 
-#: display/display.c:490
+#: display/display.c:521
 #, c-format
 msgid "  Type\t\t%s"
 msgstr ""
 
-#: display/display.c:516
+#: display/display.c:547
 msgid "--- Volume group ---"
 msgstr ""
 
-#: display/display.c:517
+#: display/display.c:548
 #, c-format
 msgid "VG Name               %s"
 msgstr ""
 
-#: display/display.c:518
+#: display/display.c:549
 #, c-format
 msgid "System ID             %s"
 msgstr ""
 
-#: display/display.c:519
+#: display/display.c:550
 #, c-format
 msgid "Format                %s"
 msgstr ""
 
-#: display/display.c:521
+#: display/display.c:552
 #, c-format
 msgid "Metadata Areas        %d"
 msgstr ""
 
-#: display/display.c:523
+#: display/display.c:554
 #, c-format
 msgid "Metadata Sequence No  %d"
 msgstr ""
 
-#: display/display.c:526
+#: display/display.c:557
 #, c-format
 msgid "VG Access             %s%s%s%s"
 msgstr ""
 
-#: display/display.c:531
+#: display/display.c:562
 #, c-format
 msgid "VG Status             %s%sresizable"
 msgstr ""
 
-#: display/display.c:538
+#: display/display.c:569
 msgid "Clustered             yes"
 msgstr ""
 
-#: display/display.c:539
+#: display/display.c:570
 #, c-format
 msgid "Shared                %s"
 msgstr ""
 
-#: display/display.c:542
+#: display/display.c:573
 #, c-format
 msgid "MAX LV                %u"
 msgstr ""
 
-#: display/display.c:543
+#: display/display.c:574
 #, c-format
 msgid "Cur LV                %u"
 msgstr ""
 
-#: display/display.c:544
+#: display/display.c:575
 #, c-format
 msgid "Open LV               %u"
 msgstr ""
 
-#: display/display.c:550
+#: display/display.c:581
 #, c-format
 msgid "Max PV                %u"
 msgstr ""
 
-#: display/display.c:551
+#: display/display.c:582
 #, c-format
 msgid "Cur PV                %u"
 msgstr ""
 
-#: display/display.c:552
+#: display/display.c:583
 #, c-format
 msgid "Act PV                %u"
 msgstr ""
 
-#: display/display.c:554
+#: display/display.c:585
 #, c-format
 msgid "VG Size               %s"
 msgstr ""
 
-#: display/display.c:559
+#: display/display.c:589
 #, c-format
 msgid "PE Size               %s"
 msgstr ""
 
-#: display/display.c:565
+#: display/display.c:594
 #, c-format
 msgid "Alloc PE / Size       %u / %s"
 msgstr ""
 
-#: display/display.c:571
+#: display/display.c:600
 #, c-format
 msgid "Free  PE / Size       %u / %s"
 msgstr ""
 
-#: display/display.c:581
+#: display/display.c:609
 #, c-format
 msgid "VG UUID               %s"
 msgstr ""
 
-#: display/display.c:617
+#: display/display.c:645
 #, c-format
-msgid "%s:%s:%d:-1:%u:%u:%u:-1:%u:%u:%u:%llu:%u:%u:%u:%u:%s"
+msgid "%s:%s:%d:-1:%u:%u:%u:-1:%u:%u:%u:%lu:%u:%u:%u:%u:%s"
 msgstr ""
 
-#: display/display.c:641
+#: display/display.c:669
 #, c-format
 msgid "\"%s\" %-9s [%-9s used / %s free]"
 msgstr ""
 
-#: display/display.c:661 display/display.c:670 pvscan.c:33
-#: report/report.c:1325 report/report.c:1477
+#: display/display.c:686 display/display.c:695 pvscan.c:34
 #, c-format
 msgid "%s"
 msgstr ""
 
-#: dumpconfig.c:26
-msgid "Please specify one file for output"
+#: error/errseg.c:73
+msgid "error module string list allocation failed"
 msgstr ""
 
-#: error/errseg.c:100 mirror/mirrored.c:315 snapshot/snapshot.c:165
-#: striped/striped.c:231 zero/zero.c:100
+#: error/errseg.c:109 mirror/mirrored.c:562 snapshot/snapshot.c:179
+#: striped/striped.c:227 zero/zero.c:109
 #, c-format
 msgid "Initialised segtype: %s"
 msgstr ""
@@ -1773,443 +1828,498 @@
 msgid "compsoite filters allocation failed"
 msgstr ""
 
-#: filters/filter-md.c:39
+#: filters/filter-md.c:31
 #, c-format
 msgid "%s: Skipping md component device"
 msgstr ""
 
-#: filters/filter-md.c:44
+#: filters/filter-md.c:36
 #, c-format
 msgid "%s: Skipping: error in md component detection"
 msgstr ""
 
-#: filters/filter-md.c:62
+#: filters/filter-md.c:54
 msgid "md filter allocation failed"
 msgstr ""
 
-#: filters/filter-persistent.c:56
+#: filters/filter-persistent.c:57
 msgid "Wiping cache of LVM-capable devices"
 msgstr ""
 
-#: filters/filter-persistent.c:72
+#: filters/filter-persistent.c:73
 #, c-format
 msgid "Couldn't find %s array in '%s'"
 msgstr ""
 
-#: filters/filter-persistent.c:83
+#: filters/filter-persistent.c:84
 msgid "Devices array contains a value which is not a string ... ignoring"
 msgstr ""
 
-#: filters/filter-persistent.c:89
+#: filters/filter-persistent.c:90
 #, c-format
 msgid "Couldn't add '%s' to filter ... ignoring"
 msgstr ""
 
-#: filters/filter-persistent.c:127
+#: filters/filter-persistent.c:108
+#, c-format
+msgid "%s: stat failed: %s"
+msgstr ""
+
+#: filters/filter-persistent.c:132
 #, c-format
 msgid "Loaded persistent filter cache from %s"
 msgstr ""
 
-#: filters/filter-persistent.c:171
+#: filters/filter-persistent.c:183
 #, c-format
 msgid "Internal persistent device cache empty - not writing to %s"
 msgstr ""
 
-#: filters/filter-persistent.c:176
+#: filters/filter-persistent.c:188
 #, c-format
 msgid "Device cache incomplete - not writing to %s"
 msgstr ""
 
-#: filters/filter-persistent.c:181
+#: filters/filter-persistent.c:193
 #, c-format
 msgid "Dumping persistent device cache to %s"
 msgstr ""
 
-#: filters/filter-persistent.c:216
+#: filters/filter-persistent.c:248 format_text/format-text.c:902
+#: format_text/format-text.c:928 format_text/format-text.c:965
+#: misc/lvm-file.c:91
+#, c-format
+msgid "%s: rename to %s failed: %s"
+msgstr ""
+
+#: filters/filter-persistent.c:276
 #, c-format
 msgid "%s: Skipping (cached)"
 msgstr ""
 
-#: filters/filter-persistent.c:252
+#: filters/filter-persistent.c:311
 msgid "Couldn't create hash table for persistent filter."
 msgstr ""
 
-#: filters/filter-regex.c:48
+#: filters/filter-regex.c:44
 msgid "pattern must begin with 'a' or 'r'"
 msgstr ""
 
-#: filters/filter-regex.c:87
+#: filters/filter-regex.c:83
 msgid "invalid separator at end of regex"
 msgstr ""
 
-#: filters/filter-regex.c:115
+#: filters/filter-regex.c:108
 msgid "filter patterns must be enclosed in quotes"
 msgstr ""
 
-#: filters/filter-regex.c:142
+#: filters/filter-regex.c:133
 msgid "invalid filter pattern"
 msgstr ""
 
-#: filters/filter-regex.c:172
-#, c-format
-msgid "%s: New preferred name"
-msgstr ""
-
-#: filters/filter-regex.c:188
+#: filters/filter-regex.c:174
 #, c-format
 msgid "%s: Skipping (regex)"
 msgstr ""
 
-#: filters/filter-sysfs.c:32
+#: filters/filter-sysfs.c:31
 msgid "No proc filesystem found: skipping sysfs filter"
 msgstr ""
 
-#: filters/filter-sysfs.c:38
+#: filters/filter-sysfs.c:37
 msgid "Failed to create /proc/mounts string"
 msgstr ""
 
-#: filters/filter-sysfs.c:136
+#: filters/filter-sysfs.c:137
 #, c-format
 msgid "Empty sysfs device file: %s"
 msgstr ""
 
-#: filters/filter-sysfs.c:141
+#: filters/filter-sysfs.c:142
 msgid "sysfs device file not correct format"
 msgstr ""
 
-#: filters/filter-sysfs.c:189
+#: filters/filter-sysfs.c:192
 #, c-format
 msgid "sysfs path name too long: %s in %s"
 msgstr ""
 
-#: filters/filter-sysfs.c:252
+#: filters/filter-sysfs.c:255
 #, c-format
 msgid "%s: Skipping (sysfs)"
 msgstr ""
 
-#: filters/filter-sysfs.c:275
+#: filters/filter-sysfs.c:278
 msgid "sysfs pool creation failed"
 msgstr ""
 
-#: filters/filter-sysfs.c:280
+#: filters/filter-sysfs.c:283
 msgid "sysfs dev_set creation failed"
 msgstr ""
 
-#: filters/filter.c:86
+#: filters/filter.c:90
+#, c-format
+msgid "%s: Skipping: Unrecognised LVM device type %lu"
+msgstr ""
+
+#: filters/filter.c:98
 #, c-format
-msgid "%s: Skipping: Unrecognised LVM device type %llu"
+msgid "%s: Skipping: Suspended dm device"
 msgstr ""
 
-#: filters/filter.c:93
+#: filters/filter.c:104
 #, c-format
 msgid "%s: Skipping: open failed"
 msgstr ""
 
-#: filters/filter.c:99
+#: filters/filter.c:110
 #, c-format
 msgid "%s: Skipping: dev_get_size failed"
 msgstr ""
 
-#: filters/filter.c:104
+#: filters/filter.c:115
 #, c-format
 msgid "%s: Skipping: Too small to hold a PV"
 msgstr ""
 
-#: filters/filter.c:109
+#: filters/filter.c:120
 #, c-format
 msgid "%s: Skipping: Partition table signature found"
 msgstr ""
 
-#: filters/filter.c:136
+#: filters/filter.c:147
 msgid "No proc filesystem found: using all block device types"
 msgstr ""
 
-#: filters/filter.c:148
+#: filters/filter.c:159
 msgid "Failed to create /proc/devices string"
 msgstr ""
 
-#: filters/filter.c:203
+#: filters/filter.c:218
 msgid "Expecting string in devices/types in config file"
 msgstr ""
 
-#: filters/filter.c:211
+#: filters/filter.c:228
 #, c-format
 msgid "Max partition count missing for %s in devices/types in config file"
 msgstr ""
 
-#: filters/filter.c:217
+#: filters/filter.c:236
 #, c-format
 msgid "Zero partition count invalid for %s in devices/types in config file"
 msgstr ""
 
-#: filters/filter.c:245
+#: filters/filter.c:269
 msgid "LVM type filter allocation failed"
 msgstr ""
 
-#: format1/disk-rep.c:189
+#: format1/disk-rep.c:190
 #, c-format
 msgid "%s does not have a valid LVM1 PV identifier"
 msgstr ""
 
-#: format1/disk-rep.c:195
+#: format1/disk-rep.c:196
 #, c-format
 msgid "format1: Unknown metadata version %d found on %s"
 msgstr ""
 
-#: format1/disk-rep.c:209 format_pool/disk_rep.c:45
+#: format1/disk-rep.c:210 format_pool/disk_rep.c:43
 #, c-format
 msgid "Failed to read PV data from %s"
 msgstr ""
 
-#: format1/disk-rep.c:359
+#: format1/disk-rep.c:367
 #, c-format
 msgid "%s is not a member of any format1 VG"
 msgstr ""
 
-#: format1/disk-rep.c:368
+#: format1/disk-rep.c:374
 #, c-format
 msgid "Failed to read VG data from PV (%s)"
 msgstr ""
 
-#: format1/disk-rep.c:376
+#: format1/disk-rep.c:380
 #, c-format
 msgid "%s is not a member of the VG %s"
 msgstr ""
 
-#: format1/disk-rep.c:382
+#: format1/disk-rep.c:390
 #, c-format
 msgid "Failed to read PV uuid list from %s"
 msgstr ""
 
-#: format1/disk-rep.c:387
+#: format1/disk-rep.c:395
 #, c-format
 msgid "Failed to read LV's from %s"
 msgstr ""
 
-#: format1/disk-rep.c:392
+#: format1/disk-rep.c:400
 #, c-format
 msgid "Failed to read extents from %s"
 msgstr ""
 
-#: format1/disk-rep.c:396
+#: format1/disk-rep.c:404
 #, c-format
 msgid "Found %s in %sVG %s"
 msgstr ""
 
-#: format1/disk-rep.c:435 format_pool/disk_rep.c:69
+#: format1/disk-rep.c:443 format_pool/disk_rep.c:67
 #, c-format
 msgid "Ignoring duplicate PV %s on %s"
 msgstr ""
 
-#: format1/disk-rep.c:440 format_pool/disk_rep.c:74
+#: format1/disk-rep.c:448 format_pool/disk_rep.c:72
 #, c-format
 msgid "Duplicate PV %s - using md %s"
 msgstr ""
 
-#: format1/disk-rep.c:486
+#: format1/disk-rep.c:494
 msgid "read_pvs_in_vg: dev_iter_create failed"
 msgstr ""
 
-#: format1/disk-rep.c:526
+#: format1/disk-rep.c:517
 #, c-format
-msgid "Too many uuids to fit on %s"
+msgid "Writing %s VG metadata to %s at %lu len %zu"
 msgstr ""
 
-#: format1/disk-rep.c:559
+#: format1/disk-rep.c:537
 #, c-format
-msgid "Couldn't zero lv area on device '%s'"
+msgid "Too many uuids to fit on %s"
 msgstr ""
 
-#: format1/disk-rep.c:567
+#: format1/disk-rep.c:542
 #, c-format
-msgid "lv_number %d too large"
+msgid "Writing %s uuidlist to %s at %lu len %d"
 msgstr ""
 
-#: format1/disk-rep.c:600
+#: format1/disk-rep.c:557
+#, c-format
+msgid "Writing %s LV %s metadata to %s at %lu len %zu"
+msgstr ""
+
+#: format1/disk-rep.c:578
+#, c-format
+msgid "Couldn't zero lv area on device '%s'"
+msgstr ""
+
+#: format1/disk-rep.c:586
+#, c-format
+msgid "lv_number %d too large"
+msgstr ""
+
+#: format1/disk-rep.c:603
+#, c-format
+msgid "Writing %s extents metadata to %s at %lu len %zu"
+msgstr ""
+
+#: format1/disk-rep.c:623
 msgid "Invalid PV structure size."
 msgstr ""
 
-#: format1/disk-rep.c:609
+#: format1/disk-rep.c:632
 msgid "Couldn't allocate temporary PV buffer."
 msgstr ""
 
-#: format1/disk-rep.c:635
+#: format1/disk-rep.c:639
+#, c-format
+msgid "Writing %s PV metadata to %s at %lu len %zu"
+msgstr ""
+
+#: format1/disk-rep.c:662
 #, c-format
 msgid "Failed to write PV structure onto %s"
 msgstr ""
 
-#: format1/disk-rep.c:654
+#: format1/disk-rep.c:681
 #, c-format
 msgid "Failed to write VG data to %s"
 msgstr ""
 
-#: format1/disk-rep.c:659
+#: format1/disk-rep.c:686
 #, c-format
 msgid "Failed to write PV uuid list to %s"
 msgstr ""
 
-#: format1/disk-rep.c:664
+#: format1/disk-rep.c:691
 #, c-format
 msgid "Failed to write LV's to %s"
 msgstr ""
 
-#: format1/disk-rep.c:669
+#: format1/disk-rep.c:696
 #, c-format
 msgid "Failed to write extents to %s"
 msgstr ""
 
-#: format1/disk-rep.c:709
+#: format1/disk-rep.c:736
 #, c-format
 msgid "Successfully wrote data to %s"
 msgstr ""
 
-#: format1/format1.c:75
+#: format1/format1.c:72
 #, c-format
 msgid "VG data differs between PVs %s and %s"
 msgstr ""
 
-#: format1/format1.c:77 format1/format1.c:92
+#: format1/format1.c:74 format1/format1.c:89
 #, c-format
 msgid "VG data on %s: %s %s %u %u  %u %u %u %u %u %u %u %u %u %u %u %u %u"
 msgstr ""
 
-#: format1/format1.c:118
+#: format1/format1.c:115
 #, c-format
 msgid "%d PV(s) found for VG %s: expected %d"
 msgstr ""
 
-#: format1/format1.c:301 format_pool/format_pool.c:230
+#: format1/format1.c:294 format_pool/format_pool.c:228
 #, c-format
 msgid "Reading physical volume data %s from disk"
 msgstr ""
 
-#: format1/format1.c:342
+#: format1/format1.c:335
 #, c-format
 msgid "Physical volumes cannot be bigger than %s"
 msgstr ""
 
-#: format1/format1.c:363
+#: format1/format1.c:355
 msgid "Metadata would overwrite physical extents"
 msgstr ""
 
-#: format1/format1.c:378
+#: format1/format1.c:370
 #, c-format
 msgid "logical volumes cannot contain more than %d extents."
 msgstr ""
 
-#: format1/format1.c:383
+#: format1/format1.c:375
 #, c-format
 msgid "logical volumes cannot be larger than %s"
 msgstr ""
 
-#: format1/format1.c:465
+#: format1/format1.c:451
 #, c-format
 msgid "Extent size must be between %s and %s"
 msgstr ""
 
-#: format1/format1.c:475
+#: format1/format1.c:459
 #, c-format
 msgid "Extent size must be multiple of %s"
 msgstr ""
 
-#: format1/format1.c:483 format_text/format-text.c:71
+#: format1/format1.c:466 format_text/format-text.c:79
 msgid "Extent size must be power of 2"
 msgstr ""
 
-#: format1/format1.c:579
+#: format1/format1.c:563
 msgid "Couldn't create lvm1 label handler."
 msgstr ""
 
-#: format1/format1.c:584
+#: format1/format1.c:568
 msgid "Couldn't register lvm1 label handler."
 msgstr ""
 
-#: format1/format1.c:588 format_pool/format_pool.c:355
-#: format_text/format-text.c:1706
+#: format1/format1.c:572 format_pool/format_pool.c:354
+#: format_text/format-text.c:1994
 #, c-format
 msgid "Initialised format: %s"
 msgstr ""
 
-#: format1/import-export.c:72
+#: format1/import-export.c:75
 #, c-format
 msgid "System ID %s on %s differs from %s for volume group"
 msgstr ""
 
-#: format1/import-export.c:108
+#: format1/import-export.c:98 format_text/import_vsn1.c:220
+#: metadata/metadata.c:569 metadata/metadata.c:1542 pvresize.c:121
+#: vgreduce.c:395 vgremove.c:62
+#, c-format
+msgid "%s: Couldn't get size."
+msgstr ""
+
+#: format1/import-export.c:101 format_text/import_vsn1.c:223
+#, c-format
+msgid "Fixing up missing format1 size (%s) for PV %s"
+msgstr ""
+
+#: format1/import-export.c:108 format_text/import_vsn1.c:230
+#, c-format
+msgid "WARNING: Physical Volume %s is too large for underlying device"
+msgstr ""
+
+#: format1/import-export.c:130
 msgid "Generated system_id too long"
 msgstr ""
 
-#: format1/import-export.c:154
+#: format1/import-export.c:174
 #, c-format
 msgid "Volume group name %s too long to export"
 msgstr ""
 
-#: format1/import-export.c:392
+#: format1/import-export.c:412
 #, c-format
 msgid "Segment type %s in LV %s: unsupported by format1"
 msgstr ""
 
-#: format1/import-export.c:398
+#: format1/import-export.c:418
 #, c-format
 msgid "Non-PV stripe found in LV %s: unsupported by format1"
 msgstr ""
 
-#: format1/import-export.c:590
+#: format1/import-export.c:610
 msgid "Logical volume number out of bounds."
 msgstr ""
 
-#: format1/import-export.c:597
+#: format1/import-export.c:617
 #, c-format
 msgid "Couldn't find logical volume '%s'."
 msgstr ""
 
-#: format1/import-export.c:617
+#: format1/import-export.c:637
 #, c-format
 msgid "Couldn't find origin logical volume for snapshot '%s'."
 msgstr ""
 
-#: format1/import-export.c:630
+#: format1/import-export.c:650
 msgid "Couldn't add snapshot."
 msgstr ""
 
-#: format1/import-extents.c:55
+#: format1/import-extents.c:53
 msgid "Unable to create hash table for holding extent maps."
 msgstr ""
 
-#: format1/import-extents.c:100
+#: format1/import-extents.c:92
 #, c-format
 msgid "Physical volume (%s) contains an unknown logical volume (%s)."
 msgstr ""
 
-#: format1/import-extents.c:145
-msgid "invalid lv in extent map"
+#: format1/import-extents.c:137
+#, c-format
+msgid "Invalid LV in extent map (PV %s, PE %u, LV %u, LE %u)"
 msgstr ""
 
-#: format1/import-extents.c:152
+#: format1/import-extents.c:149
 msgid "logical extent number out of bounds"
 msgstr ""
 
-#: format1/import-extents.c:158
+#: format1/import-extents.c:155
 #, c-format
 msgid "logical extent (%u) already mapped."
 msgstr ""
 
-#: format1/import-extents.c:178
+#: format1/import-extents.c:175
 #, c-format
 msgid "Logical volume (%s) contains an incomplete mapping table."
 msgstr ""
 
-#: format1/import-extents.c:225
+#: format1/import-extents.c:229
 msgid "Failed to allocate linear segment."
 msgstr ""
 
-#: format1/import-extents.c:273
+#: format1/import-extents.c:276
 #, c-format
 msgid ""
 "Number of stripes (%u) incompatible with logical extent count (%u) for %s"
 msgstr ""
 
-#: format1/import-extents.c:301
+#: format1/import-extents.c:303
 msgid "Failed to allocate striped segment."
 msgstr ""
 
@@ -2225,26 +2335,26 @@
 msgid "Couldn't build extent segments."
 msgstr ""
 
-#: format1/layout.c:77
+#: format1/layout.c:79
 #, c-format
 msgid "MaxLogicalVolumes of %d exceeds format limit of %d for VG '%s'"
 msgstr ""
 
-#: format1/layout.c:84
+#: format1/layout.c:86
 #, c-format
 msgid "MaxPhysicalVolumes of %d exceeds format limit of %d for VG '%s'"
 msgstr ""
 
-#: format1/layout.c:103
+#: format1/layout.c:105
 msgid "Insufficient space for metadata and PE's."
 msgstr ""
 
-#: format1/layout.c:139
+#: format1/layout.c:141
 #, c-format
 msgid "Too few extents on %s.  Try smaller extent size."
 msgstr ""
 
-#: format1/layout.c:160
+#: format1/layout.c:162
 #, c-format
 msgid "Metadata extent limit (%u) exceeded for %s - %u required"
 msgstr ""
@@ -2254,96 +2364,96 @@
 msgid "The '%s' operation is not supported for the lvm1 labeller."
 msgstr ""
 
-#: format1/lvm1-label.c:111 format_pool/pool_label.c:100
-#: format_text/text_label.c:276
+#: format1/lvm1-label.c:120 format_pool/pool_label.c:99
+#: format_text/text_label.c:285
 msgid "Couldn't allocate labeller object."
 msgstr ""
 
-#: format_pool/disk_rep.c:96 format_pool/disk_rep.c:100
+#: format_pool/disk_rep.c:94 format_pool/disk_rep.c:98
 #, c-format
 msgid "Calculated uuid %s for %s"
 msgstr ""
 
-#: format_pool/disk_rep.c:276
+#: format_pool/disk_rep.c:274
 #, c-format
 msgid "Unable to allocate %d 32-bit uints"
 msgstr ""
 
-#: format_pool/disk_rep.c:343
+#: format_pool/disk_rep.c:341
 #, c-format
 msgid "No devices for vg %s found in cache"
 msgstr ""
 
-#: format_pool/disk_rep.c:365
+#: format_pool/disk_rep.c:363
 msgid "Unable to allocate pool list structure"
 msgstr ""
 
-#: format_pool/format_pool.c:47
+#: format_pool/format_pool.c:44
 #, c-format
 msgid "Unable to allocate %d subpool structures"
 msgstr ""
 
-#: format_pool/format_pool.c:67
+#: format_pool/format_pool.c:64
 #, c-format
 msgid "Unable to allocate %d pool_device structures"
 msgstr ""
 
-#: format_pool/format_pool.c:89
+#: format_pool/format_pool.c:87
 #, c-format
 msgid "Missing subpool %d in pool %s"
 msgstr ""
 
-#: format_pool/format_pool.c:94
+#: format_pool/format_pool.c:92
 #, c-format
-msgid "Missing device %d for subpool %d in pool %s"
+msgid "Missing device %u for subpool %d in pool %s"
 msgstr ""
 
-#: format_pool/format_pool.c:115
+#: format_pool/format_pool.c:113
 msgid "Unable to allocate volume group structure"
 msgstr ""
 
-#: format_pool/format_pool.c:280
+#: format_pool/format_pool.c:279
 msgid "Unable to allocate format instance structure for pool format"
 msgstr ""
 
-#: format_pool/format_pool.c:290
+#: format_pool/format_pool.c:289
 msgid "Unable to allocate metadata area structure for pool format"
 msgstr ""
 
-#: format_pool/format_pool.c:333
+#: format_pool/format_pool.c:332
 msgid "Unable to allocate format type structure for pool format"
 msgstr ""
 
-#: format_pool/format_pool.c:346
+#: format_pool/format_pool.c:345
 msgid "Couldn't create pool label handler."
 msgstr ""
 
-#: format_pool/format_pool.c:351
+#: format_pool/format_pool.c:350
 msgid "Couldn't register pool label handler."
 msgstr ""
 
-#: format_pool/import_export.c:65
+#: format_pool/import_export.c:64
 msgid "Unable to allocate lv list structure"
 msgstr ""
 
-#: format_pool/import_export.c:70
+#: format_pool/import_export.c:69
 msgid "Unable to allocate logical volume structure"
 msgstr ""
 
-#: format_pool/import_export.c:99
+#: format_pool/import_export.c:98
 #, c-format
 msgid "Calculated lv uuid for lv %s: %s"
 msgstr ""
 
-#: format_pool/import_export.c:134
+#: format_pool/import_export.c:133
 msgid "Unable to allocate pv list structure"
 msgstr ""
 
-#: format_pool/import_export.c:138
+#: format_pool/import_export.c:137
 msgid "Unable to allocate pv structure"
 msgstr ""
 
-#: format_pool/import_export.c:166
+#: format_pool/import_export.c:165
 msgid "Unable to duplicate vg_name string"
 msgstr ""
 
@@ -2364,71 +2474,71 @@
 msgid "Unable to allocate linear lv_segment structure"
 msgstr ""
 
-#: format_pool/pool_label.c:29
+#: format_pool/pool_label.c:28
 #, c-format
 msgid "The '%s' operation is not supported for the pool labeller."
 msgstr ""
 
-#: format_text/archive.c:148
+#: format_text/archive.c:146
 #, c-format
 msgid "Couldn't scan the archive directory (%s)."
 msgstr ""
 
-#: format_text/archive.c:175
+#: format_text/archive.c:173
 msgid "Couldn't create new archive file."
 msgstr ""
 
-#: format_text/archive.c:223
+#: format_text/archive.c:221
 #, c-format
 msgid "Expiring archive %s"
 msgstr ""
 
-#: format_text/archive.c:248
+#: format_text/archive.c:246
 msgid "Couldn't create temporary archive name."
 msgstr ""
 
-#: format_text/archive.c:253
+#: format_text/archive.c:251
 msgid "Couldn't create FILE object for archive."
 msgstr ""
 
-#: format_text/archive.c:284
+#: format_text/archive.c:288
 msgid "Archive file name too long."
 msgstr ""
 
-#: format_text/archive.c:295
+#: format_text/archive.c:299
 #, c-format
 msgid "Archive rename failed for %s"
 msgstr ""
 
-#: format_text/archive.c:312
+#: format_text/archive.c:316
 #, c-format
 msgid "File:\t\t%s"
 msgstr ""
 
-#: format_text/archive.c:317
+#: format_text/archive.c:321
 msgid "Couldn't create text instance object."
 msgstr ""
 
-#: format_text/archive.c:327
+#: format_text/archive.c:331
 msgid "Unable to read archive file."
 msgstr ""
 
-#: format_text/archive.c:332
+#: format_text/archive.c:336
 #, c-format
 msgid "VG name:    \t%s"
 msgstr ""
 
-#: format_text/archive.c:333
+#: format_text/archive.c:337
 #, c-format
 msgid "Description:\t%s"
 msgstr ""
 
-#: format_text/archive.c:334
+#: format_text/archive.c:338
 #, c-format
 msgid "Backup Time:\t%s"
 msgstr ""
 
-#: format_text/archive.c:351
+#: format_text/archive.c:355
 #, c-format
 msgid "No archives found in %s."
 msgstr ""
@@ -2456,562 +2566,611 @@
 msgid "Failed to generate backup filename."
 msgstr ""
 
-#: format_text/export.c:69
+#: format_text/export.c:80
 #, c-format
 msgid "uname failed: %s"
 msgstr ""
 
-#: format_text/export.c:90
+#: format_text/export.c:101
 msgid "Internal error tracking indentation"
 msgstr ""
 
-#: format_text/export.c:740
+#: format_text/export.c:120
+#, c-format
+msgid "Doubling metadata output buffer to %u"
+msgstr ""
+
+#: format_text/export.c:124
+msgid "Buffer reallocation failed."
+msgstr ""
+
+#: format_text/export.c:737
 msgid "text_export buffer allocation failed"
 msgstr ""
 
-#: format_text/flags.c:76
+#: format_text/flags.c:79
 msgid "Unknown flag set requested."
 msgstr ""
 
-#: format_text/flags.c:122
+#: format_text/flags.c:125
 msgid "Metadata inconsistency: Not all flags successfully exported."
 msgstr ""
 
-#: format_text/flags.c:144
+#: format_text/flags.c:147
 msgid "Status value is not a string."
 msgstr ""
 
-#: format_text/flags.c:155
+#: format_text/flags.c:158
 #, c-format
 msgid "Unknown status flag '%s'."
 msgstr ""
 
-#: format_text/format-text.c:92
+#: format_text/format-text.c:152
+#, c-format
+msgid "Found text metadata area, offset=%lu, size=%lu"
+msgstr ""
+
+#: format_text/format-text.c:207
+#, c-format
+msgid ""
+"Found LVM2 metadata record at offset=%lu, size=%lu, offset2=%lu size2=%lu"
+msgstr ""
+
+#: format_text/format-text.c:259
 #, c-format
 msgid "Random lvid creation failed for %s/%s."
 msgstr ""
 
-#: format_text/format-text.c:123
+#: format_text/format-text.c:290
 msgid "struct mda_header allocation failed"
 msgstr ""
 
-#: format_text/format-text.c:136
+#: format_text/format-text.c:302
 msgid "Incorrect metadata area header checksum"
 msgstr ""
 
-#: format_text/format-text.c:143
+#: format_text/format-text.c:309
 msgid "Wrong magic number in metadata area header"
 msgstr ""
 
-#: format_text/format-text.c:148
+#: format_text/format-text.c:314
 #, c-format
 msgid "Incompatible metadata area header version: %d"
 msgstr ""
 
-#: format_text/format-text.c:154
+#: format_text/format-text.c:320
 #, c-format
-msgid "Incorrect start sector in metadata area header: %llu"
+msgid "Incorrect start sector in metadata area header: %lu"
 msgstr ""
 
-#: format_text/format-text.c:285
+#: format_text/format-text.c:461
 #, c-format
 msgid "VG %s not found on %s"
 msgstr ""
 
-#: format_text/format-text.c:293 format_text/format-text.c:390
+#: format_text/format-text.c:469 format_text/format-text.c:574
 #, c-format
 msgid "VG %s metadata too large for circular buffer"
 msgstr ""
 
-#: format_text/format-text.c:308
+#: format_text/format-text.c:484
 #, c-format
-msgid "Read %s %smetadata (%u) from %s at %llu size %llu"
+msgid "Read %s %smetadata (%u) from %s at %lu size %lu"
 msgstr ""
 
-#: format_text/format-text.c:375
+#: format_text/format-text.c:557
 #, c-format
 msgid "VG %s metadata writing failed"
 msgstr ""
 
-#: format_text/format-text.c:395
+#: format_text/format-text.c:579
+#, c-format
+msgid "Writing %s metadata to %s at %lu len %lu"
+msgstr ""
+
+#: format_text/format-text.c:592
 #, c-format
-msgid "Writing %s metadata to %s at %llu len %llu"
+msgid "Writing metadata to %s at %lu len %u"
 msgstr ""
 
-#: format_text/format-text.c:407
+#: format_text/format-text.c:681
 #, c-format
-msgid "Writing metadata to %s at %llu len %u"
+msgid "%sCommitting %s metadata (%u) to %s header at %lu"
 msgstr ""
 
-#: format_text/format-text.c:481
+#: format_text/format-text.c:685
 #, c-format
-msgid "%sCommitting %s metadata (%u) to %s header at %llu"
+msgid "Wiping pre-committed %s metadata from %s header at %lu"
 msgstr ""
 
-#: format_text/format-text.c:486 format_text/format-text.c:566
+#: format_text/format-text.c:691 format_text/format-text.c:777
 msgid "Failed to write metadata area header"
 msgstr ""
 
-#: format_text/format-text.c:599
+#: format_text/format-text.c:810
 #, c-format
 msgid "'%s' does not contain volume group '%s'."
 msgstr ""
 
-#: format_text/format-text.c:603
+#: format_text/format-text.c:814
 #, c-format
 msgid "Read volume group %s from %s"
 msgstr ""
 
-#: format_text/format-text.c:646
+#: format_text/format-text.c:863
 msgid "Text format failed to determine directory."
 msgstr ""
 
-#: format_text/format-text.c:651
+#: format_text/format-text.c:868
 msgid "Couldn't create temporary text file name."
 msgstr ""
 
-#: format_text/format-text.c:661
+#: format_text/format-text.c:879
 #, c-format
 msgid "Writing %s metadata to %s"
 msgstr ""
 
-#: format_text/format-text.c:664
+#: format_text/format-text.c:882
 #, c-format
 msgid "Failed to write metadata to %s."
 msgstr ""
 
-#: format_text/format-text.c:682 format_text/format-text.c:708
-#: format_text/format-text.c:745 misc/lvm-file.c:90
+#: format_text/format-text.c:901 format_text/format-text.c:926
+#: format_text/format-text.c:960
 #, c-format
-msgid "%s: rename to %s failed: %s"
+msgid "Renaming %s to %s"
 msgstr ""
 
-#: format_text/format-text.c:697
+#: format_text/format-text.c:917
 #, c-format
 msgid "Test mode: Skipping committing %s metadata (%u)"
 msgstr ""
 
-#: format_text/format-text.c:700
+#: format_text/format-text.c:920
 #, c-format
 msgid "Unlinking %s"
 msgstr ""
 
-#: format_text/format-text.c:705
+#: format_text/format-text.c:925
 #, c-format
 msgid "Committing %s metadata (%u)"
 msgstr ""
 
-#: format_text/format-text.c:742
+#: format_text/format-text.c:962
 msgid "Test mode: Skipping rename"
 msgstr ""
 
-#: format_text/format-text.c:805 format_text/format-text.c:1438
+#: format_text/format-text.c:1025 format_text/format-text.c:1723
 #, c-format
 msgid "Name too long %s/%s"
 msgstr ""
 
-#: format_text/format-text.c:933
+#: format_text/format-text.c:1089
+#, c-format
+msgid "%s: metadata too large for circular buffer"
+msgstr ""
+
+#: format_text/format-text.c:1118
+#, c-format
+msgid "%s: Found metadata at %lu size %lu for %s (%s)"
+msgstr ""
+
+#: format_text/format-text.c:1186
 #, c-format
 msgid "Physical extents end beyond end of device %s!"
 msgstr ""
 
-#: format_text/format-text.c:960
+#: format_text/format-text.c:1207
 #, c-format
 msgid "Warning: metadata area fills disk leaving no space for data on %s."
 msgstr ""
 
-#: format_text/format-text.c:990 format_text/format-text.c:1036
+#: format_text/format-text.c:1238 format_text/format-text.c:1283
 msgid "Failed to wipe new metadata area"
 msgstr ""
 
-#: format_text/format-text.c:1083
+#: format_text/format-text.c:1329
 #, c-format
-msgid "Creating metadata area on %s at sector %llu size %llu sectors"
+msgid "Creating metadata area on %s at sector %lu size %lu sectors"
 msgstr ""
 
-#: format_text/format-text.c:1164
+#: format_text/format-text.c:1410
 msgid "_add_raw allocation failed"
 msgstr ""
 
-#: format_text/format-text.c:1223
+#: format_text/format-text.c:1470
 #, c-format
 msgid "Must be exactly one data area (found %d) on PV %s"
 msgstr ""
 
-#: format_text/format-text.c:1238 format_text/format-text.c:1242
+#: format_text/format-text.c:1485 format_text/format-text.c:1489
 msgid "metadata_area allocation failed"
 msgstr ""
 
-#: format_text/format-text.c:1416
+#: format_text/format-text.c:1650
+#, c-format
+msgid "PV %s too large for extent size %s."
+msgstr ""
+
+#: format_text/format-text.c:1693
 msgid "Couldn't allocate format instance object."
 msgstr ""
 
-#: format_text/format-text.c:1523
+#: format_text/format-text.c:1699
+msgid "Couldn't allocate text_fid_context."
+msgstr ""
+
+#: format_text/format-text.c:1807
 #, c-format
 msgid "%s: Volume group filename may not end in .tmp"
 msgstr ""
 
-#: format_text/format-text.c:1557
+#: format_text/format-text.c:1841
 msgid "Couldn't allocate text format context object."
 msgstr ""
 
-#: format_text/format-text.c:1579
+#: format_text/format-text.c:1863
 msgid "_add_dir allocation failed"
 msgstr ""
 
-#: format_text/format-text.c:1582
+#: format_text/format-text.c:1866
 #, c-format
 msgid "Adding text format metadata dir: %s"
 msgstr ""
 
-#: format_text/format-text.c:1599
+#: format_text/format-text.c:1883
 msgid "Empty metadata disk_area section of config file"
 msgstr ""
 
-#: format_text/format-text.c:1604
+#: format_text/format-text.c:1888
 msgid "Missing start_sector in metadata disk_area section of config file"
 msgstr ""
 
-#: format_text/format-text.c:1611
+#: format_text/format-text.c:1895
 msgid "Missing size in metadata disk_area section of config file"
 msgstr ""
 
-#: format_text/format-text.c:1618
+#: format_text/format-text.c:1902
 msgid "Missing uuid in metadata disk_area section of config file"
 msgstr ""
 
-#: format_text/format-text.c:1624
+#: format_text/format-text.c:1908
 #, c-format
 msgid "Invalid uuid in metadata disk_area section of config file: %s"
 msgstr ""
 
-#: format_text/format-text.c:1633 format_text/import_vsn1.c:156
+#: format_text/format-text.c:1917 format_text/import_vsn1.c:155
 msgid "Couldn't find device."
 msgstr ""
 
-#: format_text/format-text.c:1635 format_text/import_vsn1.c:158
+#: format_text/format-text.c:1919 format_text/import_vsn1.c:157
 #, c-format
 msgid "Couldn't find device with uuid '%s'."
 msgstr ""
 
-#: format_text/format-text.c:1663
+#: format_text/format-text.c:1948
 msgid "Failed to allocate dir_list"
 msgstr ""
 
-#: format_text/format-text.c:1674
+#: format_text/format-text.c:1960
 msgid "Couldn't create text label handler."
 msgstr ""
 
-#: format_text/format-text.c:1679
+#: format_text/format-text.c:1966
 msgid "Couldn't register text label handler."
 msgstr ""
 
-#: format_text/format-text.c:1686
+#: format_text/format-text.c:1974
 msgid "Invalid string in config file: metadata/dirs"
 msgstr ""
 
-#: format_text/import.c:60
+#: format_text/import.c:103
 msgid "Couldn't read volume group metadata."
 msgstr ""
 
-#: format_text/import_vsn1.c:48
+#: format_text/import_vsn1.c:46
 #, c-format
 msgid "Can't process text format file - %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:96
+#: format_text/import_vsn1.c:94
 msgid "Couldn't find uuid."
 msgstr ""
 
-#: format_text/import_vsn1.c:102
+#: format_text/import_vsn1.c:100
 msgid "uuid must be a string."
 msgstr ""
 
-#: format_text/import_vsn1.c:107
+#: format_text/import_vsn1.c:105
 msgid "Invalid uuid."
 msgstr ""
 
-#: format_text/import_vsn1.c:140
+#: format_text/import_vsn1.c:139
 msgid "Empty pv section."
 msgstr ""
 
-#: format_text/import_vsn1.c:145
+#: format_text/import_vsn1.c:144
 msgid "Couldn't read uuid for volume group."
 msgstr ""
 
-#: format_text/import_vsn1.c:173
+#: format_text/import_vsn1.c:174
 msgid "Couldn't find status flags for physical volume."
 msgstr ""
 
-#: format_text/import_vsn1.c:178
+#: format_text/import_vsn1.c:179
 msgid "Couldn't read status flags for physical volume."
 msgstr ""
 
-#: format_text/import_vsn1.c:183
+#: format_text/import_vsn1.c:187
 msgid "Couldn't read extent size for volume group."
 msgstr ""
 
-#: format_text/import_vsn1.c:188
+#: format_text/import_vsn1.c:192
 msgid "Couldn't find extent count (pe_count) for physical volume."
 msgstr ""
 
-#: format_text/import_vsn1.c:199
+#: format_text/import_vsn1.c:203
 #, c-format
 msgid "Couldn't read tags for physical volume %s in %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:252
+#: format_text/import_vsn1.c:275
 msgid "Empty segment section."
 msgstr ""
 
-#: format_text/import_vsn1.c:257
+#: format_text/import_vsn1.c:280
 #, c-format
 msgid "Couldn't read 'start_extent' for segment '%s'."
 msgstr ""
 
-#: format_text/import_vsn1.c:263
+#: format_text/import_vsn1.c:286
 #, c-format
 msgid "Couldn't read 'extent_count' for segment '%s'."
 msgstr ""
 
-#: format_text/import_vsn1.c:273
+#: format_text/import_vsn1.c:296
 msgid "Segment type must be a string."
 msgstr ""
 
-#: format_text/import_vsn1.c:293
+#: format_text/import_vsn1.c:316
 msgid "Segment allocation failed"
 msgstr ""
 
-#: format_text/import_vsn1.c:306
+#: format_text/import_vsn1.c:329
 #, c-format
 msgid "Couldn't read tags for a segment of %s/%s."
 msgstr ""
 
-#: format_text/import_vsn1.c:335
+#: format_text/import_vsn1.c:358
 #, c-format
 msgid "Zero areas not allowed for segment '%s'"
 msgstr ""
 
-#: format_text/import_vsn1.c:371
+#: format_text/import_vsn1.c:394
 #, c-format
 msgid "Couldn't find volume '%s' for segment '%s'."
 msgstr ""
 
-#: format_text/import_vsn1.c:384
+#: format_text/import_vsn1.c:407
 #, c-format
 msgid "Incorrect number of areas in area array for segment '%s'."
 msgstr ""
 
-#: format_text/import_vsn1.c:414
+#: format_text/import_vsn1.c:437
 msgid "Only one segment permitted for snapshot"
 msgstr ""
 
-#: format_text/import_vsn1.c:420
+#: format_text/import_vsn1.c:443
 msgid "Couldn't read segment count for logical volume."
 msgstr ""
 
-#: format_text/import_vsn1.c:425
+#: format_text/import_vsn1.c:448
 msgid "segment_count and actual number of segments disagree."
 msgstr ""
 
-#: format_text/import_vsn1.c:471 format_text/import_vsn1.c:539
+#: format_text/import_vsn1.c:494 format_text/import_vsn1.c:562
 msgid "Empty logical volume section."
 msgstr ""
 
-#: format_text/import_vsn1.c:476
+#: format_text/import_vsn1.c:499
 msgid "Couldn't find status flags for logical volume."
 msgstr ""
 
-#: format_text/import_vsn1.c:481
+#: format_text/import_vsn1.c:504
 msgid "Couldn't read status flags for logical volume."
 msgstr ""
 
-#: format_text/import_vsn1.c:489 format_text/import_vsn1.c:710
+#: format_text/import_vsn1.c:512 format_text/import_vsn1.c:729
 msgid "allocation_policy must be a string."
 msgstr ""
 
-#: format_text/import_vsn1.c:512
+#: format_text/import_vsn1.c:535
 #, c-format
 msgid "Couldn't read tags for logical volume %s/%s."
 msgstr ""
 
-#: format_text/import_vsn1.c:532
+#: format_text/import_vsn1.c:555
 #, c-format
 msgid "Lost logical volume reference %s"
 msgstr ""
 
-#: format_text/import_vsn1.c:545
+#: format_text/import_vsn1.c:568
 #, c-format
 msgid "Couldn't read uuid for logical volume %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:572
+#: format_text/import_vsn1.c:595
 #, c-format
 msgid "Couldn't read minor number for logical volume %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:580
+#: format_text/import_vsn1.c:603
 #, c-format
 msgid "Couldn't read major number for logical volume %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:597
+#: format_text/import_vsn1.c:620
 #, c-format
 msgid "Couldn't find section '%s'."
 msgstr ""
 
-#: format_text/import_vsn1.c:626
+#: format_text/import_vsn1.c:649 format_text/import_vsn1.c:841
 msgid "Couldn't find volume group in file."
 msgstr ""
 
-#: format_text/import_vsn1.c:654
+#: format_text/import_vsn1.c:673
 msgid "system_id must be a string"
 msgstr ""
 
-#: format_text/import_vsn1.c:661
+#: format_text/import_vsn1.c:680 format_text/import_vsn1.c:851
 #, c-format
 msgid "Couldn't read uuid for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:666
+#: format_text/import_vsn1.c:685
 #, c-format
 msgid "Couldn't read 'seqno' for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:672
+#: format_text/import_vsn1.c:691 format_text/import_vsn1.c:856
 #, c-format
 msgid "Couldn't find status flags for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:678
+#: format_text/import_vsn1.c:697 format_text/import_vsn1.c:862
 #, c-format
 msgid "Couldn't read status flags for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:684
+#: format_text/import_vsn1.c:703
 #, c-format
 msgid "Couldn't read extent size for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:695
+#: format_text/import_vsn1.c:714
 #, c-format
 msgid "Couldn't read 'max_lv' for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:701
+#: format_text/import_vsn1.c:720
 #, c-format
 msgid "Couldn't read 'max_pv' for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:726
+#: format_text/import_vsn1.c:745
 msgid "Couldn't create hash table."
 msgstr ""
 
-#: format_text/import_vsn1.c:733
+#: format_text/import_vsn1.c:752
 #, c-format
 msgid "Couldn't find all physical volumes for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:744
+#: format_text/import_vsn1.c:763
 #, c-format
 msgid "Couldn't read tags for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:750
+#: format_text/import_vsn1.c:769
 #, c-format
 msgid "Couldn't read all logical volume names for volume group %s."
 msgstr ""
 
-#: format_text/import_vsn1.c:757
+#: format_text/import_vsn1.c:776
 #, c-format
 msgid "Couldn't read all logical volumes for volume group %s."
 msgstr ""
 
-#: format_text/tags.c:63
+#: format_text/import_vsn1.c:782
+#, c-format
+msgid "Failed to fixup mirror pointers after import for volume group %s."
+msgstr ""
+
+#: format_text/tags.c:62
 msgid "Found a tag that is not a string"
 msgstr ""
 
-#: format_text/text_label.c:96 format_text/text_label.c:101
+#: format_text/text_label.c:98 format_text/text_label.c:103
 msgid "struct data_area_list allocation failed"
 msgstr ""
 
-#: format_text/text_label.c:136 format_text/text_label.c:147
+#: format_text/text_label.c:138 format_text/text_label.c:149
 msgid "struct mda_list allocation failed"
 msgstr ""
 
-#: format_text/text_label.c:141 format_text/text_label.c:152
+#: format_text/text_label.c:143 format_text/text_label.c:154
 msgid "struct mda_context allocation failed"
 msgstr ""
 
-#: label/label.c:50
+#: label/label.c:49
 msgid "Couldn't allocate memory for labeller list object."
 msgstr ""
 
-#: label/label.c:131 label/label.c:225
+#: label/label.c:123 label/label.c:218
 #, c-format
 msgid "%s: Failed to read label area"
 msgstr ""
 
-#: label/label.c:143 label/label.c:170
+#: label/label.c:135 label/label.c:164
 #, c-format
-msgid "Ignoring additional label on %s at sector %llu"
+msgid "Ignoring additional label on %s at sector %lu"
 msgstr ""
 
-#: label/label.c:148
+#: label/label.c:140
 #, c-format
-msgid "%s: Label for sector %llu found at sector %llu - ignoring"
+msgid "%s: Label for sector %lu found at sector %lu - ignoring"
 msgstr ""
 
-#: label/label.c:157
+#: label/label.c:150
 #, c-format
 msgid "Label checksum incorrect on %s - ignoring"
 msgstr ""
 
-#: label/label.c:167
+#: label/label.c:161
 #, c-format
 msgid "%s: %s label detected"
 msgstr ""
 
-#: label/label.c:189
+#: label/label.c:185
 #, c-format
 msgid "%s: No label detected"
 msgstr ""
 
-#: label/label.c:211
+#: label/label.c:204
 #, c-format
 msgid "Scanning for labels to wipe from %s"
 msgstr ""
 
-#: label/label.c:251
+#: label/label.c:244
 #, c-format
-msgid "%s: Wiping label at sector %llu"
+msgid "%s: Wiping label at sector %lu"
 msgstr ""
 
-#: label/label.c:255
+#: label/label.c:248
 #, c-format
-msgid "Failed to remove label from %s at sector %llu"
+msgid "Failed to remove label from %s at sector %lu"
 msgstr ""
 
-#: label/label.c:297
+#: label/label.c:304
 msgid "Label handler does not support label writes"
 msgstr ""
 
-#: label/label.c:302
+#: label/label.c:309
 #, c-format
-msgid "Label sector %llu beyond range (%ld)"
+msgid "Label sector %lu beyond range (%ld)"
 msgstr ""
 
-#: label/label.c:326
+#: label/label.c:333
 #, c-format
-msgid "%s: Writing label to sector %llu"
+msgid "%s: Writing label to sector %lu"
 msgstr ""
 
-#: label/label.c:329
+#: label/label.c:336
 #, c-format
 msgid "Failed to write label to %s"
 msgstr ""
 
-#: label/label.c:364
+#: label/label.c:386
 msgid "label allocaction failed"
 msgstr ""
 
@@ -3044,37 +3203,37 @@
 msgid "cluster request failed: %s"
 msgstr ""
 
-#: locking/cluster_locking.c:351
+#: locking/cluster_locking.c:346
 #, c-format
 msgid "clvmd not running on node %s"
 msgstr ""
 
-#: locking/cluster_locking.c:356
+#: locking/cluster_locking.c:351
 #, c-format
 msgid "Error locking on node %s: %s"
 msgstr ""
 
-#: locking/cluster_locking.c:406 locking/file_locking.c:264
-#: locking/locking.c:247 locking/no_locking.c:71
+#: locking/cluster_locking.c:402 locking/file_locking.c:266
+#: locking/locking.c:265 locking/no_locking.c:71
 #, c-format
 msgid "Unrecognised lock scope: %d"
 msgstr ""
 
-#: locking/cluster_locking.c:412
+#: locking/cluster_locking.c:408
 #, c-format
 msgid "Locking %s at 0x%x"
 msgstr ""
 
-#: locking/external_locking.c:63
+#: locking/external_locking.c:64
 msgid "External locking already initialised"
 msgstr ""
 
-#: locking/external_locking.c:85
+#: locking/external_locking.c:86
 #, c-format
 msgid "Shared library %s does not contain locking functions"
 msgstr ""
 
-#: locking/external_locking.c:92
+#: locking/external_locking.c:93
 #, c-format
 msgid "Loaded external locking library %s"
 msgstr ""
@@ -3098,699 +3257,912 @@
 msgid "Locking %s %c%c"
 msgstr ""
 
-#: locking/file_locking.c:235
+#: locking/file_locking.c:237
 #, c-format
 msgid "Unlocking LV %s"
 msgstr ""
 
-#: locking/file_locking.c:240
+#: locking/file_locking.c:242
 #, c-format
 msgid "Locking LV %s (NL)"
 msgstr ""
 
-#: locking/file_locking.c:245
+#: locking/file_locking.c:247
 #, c-format
 msgid "Locking LV %s (R)"
 msgstr ""
 
-#: locking/file_locking.c:250
+#: locking/file_locking.c:252
 #, c-format
 msgid "Locking LV %s (W)"
 msgstr ""
 
-#: locking/file_locking.c:255
+#: locking/file_locking.c:257
 #, c-format
 msgid "Locking LV %s (EX)"
 msgstr ""
 
-#: locking/locking.c:132
+#: locking/locking.c:133
 msgid ""
 "WARNING: Locking disabled. Be careful! This could corrupt your metadata."
 msgstr ""
 
-#: locking/locking.c:139
-msgid "File-based locking enabled."
+#: locking/locking.c:138
+msgid "File-based locking selected."
 msgstr ""
 
 #: locking/locking.c:146
-msgid "External locking enabled."
+msgid "External locking selected."
 msgstr ""
 
-#: locking/locking.c:154
-msgid "Cluster locking enabled."
+#: locking/locking.c:156
+msgid "Falling back to internal clustered locking."
 msgstr ""
 
-#: locking/locking.c:159
-msgid "Unknown locking type requested."
+#: locking/locking.c:160
+msgid "Cluster locking selected."
 msgstr ""
 
 #: locking/locking.c:167
+msgid "Unknown locking type requested."
+msgstr ""
+
+#: locking/locking.c:174
+msgid "WARNING: Falling back to local file-based locking."
+msgstr ""
+
+#: locking/locking.c:175
+msgid "Volume Groups with the clustered attribute will be inaccessible."
+msgstr ""
+
+#: locking/locking.c:185
 msgid "Locking disabled - only read operations permitted."
 msgstr ""
 
-#: locking/locking.c:194
+#: locking/locking.c:212
 #, c-format
 msgid "LVM1 proc VG pathname too long for %s"
 msgstr ""
 
-#: locking/locking.c:199
+#: locking/locking.c:217
 #, c-format
 msgid "%s exists: Is the original LVM driver using this volume group?"
 msgstr ""
 
-#: locking/locking.c:284 lvresize.c:526
+#: locking/locking.c:302 lvresize.c:573
 #, c-format
 msgid "Failed to suspend %s"
 msgstr ""
 
-#: locking/locking.c:305
+#: locking/locking.c:323
 #, c-format
 msgid "Failed to activate %s"
 msgstr ""
 
-#: log/log.c:135
+#: log/log.c:145
 msgid "Test mode: Metadata will NOT be updated."
 msgstr ""
 
-#: log/log.c:264
-msgid "vsnprintf failed: skipping external logging function"
-msgstr ""
-
-#: lvchange.c:26
+#: lvchange.c:27
 #, c-format
 msgid "Logical volume \"%s\" is already writable"
 msgstr ""
 
-#: lvchange.c:32
+#: lvchange.c:33
 #, c-format
 msgid "Logical volume \"%s\" is already read only"
 msgstr ""
 
-#: lvchange.c:39
+#: lvchange.c:40
+#, c-format
+msgid "Cannot change permissions of mirror \"%s\" while active."
+msgstr ""
+
+#: lvchange.c:47
 #, c-format
 msgid "Setting logical volume \"%s\" read/write"
 msgstr ""
 
-#: lvchange.c:43
+#: lvchange.c:51
 #, c-format
 msgid "Setting logical volume \"%s\" read-only"
 msgstr ""
 
-#: lvchange.c:47 lvchange.c:168 lvchange.c:211 lvchange.c:296 lvchange.c:354
-#: lvconvert.c:87
+#: lvchange.c:55 lvchange.c:314 lvchange.c:350 lvchange.c:393 lvchange.c:470
+#: lvchange.c:524 lvconvert.c:401
 #, c-format
 msgid "Updating logical volume \"%s\" on disk(s)"
 msgstr ""
 
-#: lvchange.c:56 lvchange.c:220 lvchange.c:305 lvconvert.c:97
+#: lvchange.c:64 lvchange.c:402 lvconvert.c:409 metadata/mirror.c:227
 #, c-format
 msgid "Failed to lock %s"
 msgstr ""
 
-#: lvchange.c:66 lvchange.c:230 lvchange.c:315
+#: lvchange.c:74 lvchange.c:412
 #, c-format
 msgid "Updating permissions for \"%s\" in kernel"
 msgstr ""
 
-#: lvchange.c:68 lvchange.c:232 lvchange.c:317 lvconvert.c:110 lvresize.c:538
+#: lvchange.c:76 lvchange.c:414 lvconvert.c:422 lvresize.c:585
+#: metadata/mirror.c:240
 #, c-format
 msgid "Problem reactivating %s"
 msgstr ""
 
-#: lvchange.c:84
+#: lvchange.c:89
+#, c-format
+msgid "Logical volume, %s, is not active"
+msgstr ""
+
+#: lvchange.c:113
 #, c-format
 msgid "Deactivating logical volume \"%s\" locally"
 msgstr ""
 
-#: lvchange.c:91
+#: lvchange.c:120
 #, c-format
 msgid "Deactivating logical volume \"%s\""
 msgstr ""
 
-#: lvchange.c:98
+#: lvchange.c:127
 #, c-format
 msgid "Locking failed: ignoring clustered logical volume %s"
 msgstr ""
 
-#: lvchange.c:104
+#: lvchange.c:133
 #, c-format
 msgid "Activating logical volume \"%s\" exclusively"
 msgstr ""
 
-#: lvchange.c:111
+#: lvchange.c:140
 #, c-format
 msgid "Activating logical volume \"%s\" locally"
 msgstr ""
 
-#: lvchange.c:118
+#: lvchange.c:147
 #, c-format
 msgid "Activating logical volume \"%s\""
 msgstr ""
 
-#: lvchange.c:128
+#: lvchange.c:157
 #, c-format
 msgid "Spawning background pvmove process for %s"
 msgstr ""
 
-#: lvchange.c:139
+#: lvchange.c:168
 #, c-format
 msgid "Refreshing logical volume \"%s\" (if active)"
 msgstr ""
 
-#: lvchange.c:156
+#: lvchange.c:183
+#, c-format
+msgid "Unable to resync %s because it is not mirrored."
+msgstr ""
+
+#: lvchange.c:189
+#, c-format
+msgid "Unable to resync pvmove volume %s"
+msgstr ""
+
+#: lvchange.c:194
+#, c-format
+msgid "Unable to resync locked volume %s"
+msgstr ""
+
+#: lvchange.c:200
+#, c-format
+msgid "Can't resync open logical volume \"%s\""
+msgstr ""
+
+#: lvchange.c:210
+#, c-format
+msgid "Logical volume \"%s\" not resynced"
+msgstr ""
+
+#: lvchange.c:220
+#, c-format
+msgid "Can't get exclusive access to clustered volume %s"
+msgstr ""
+
+#: lvchange.c:226
+#, c-format
+msgid "Unable to deactivate %s for resync"
+msgstr ""
+
+#: lvchange.c:232
+#, c-format
+msgid "Starting resync of %s%s%s mirror \"%s\""
+msgstr ""
+
+#: lvchange.c:246
+#, c-format
+msgid "Failed to reactivate %s to resynchronize mirror"
+msgstr ""
+
+#: lvchange.c:262
+msgid "Failed to write intermediate VG metadata."
+msgstr ""
+
+#: lvchange.c:276
+msgid "Failed to commit intermediate VG metadata."
+msgstr ""
+
+#: lvchange.c:288
+#, c-format
+msgid "Unable to activate %s for mirror log resync"
+msgstr ""
+
+#: lvchange.c:293
+#, c-format
+msgid "Clearing log device %s"
+msgstr ""
+
+#: lvchange.c:295
+#, c-format
+msgid "Unable to reset sync status for %s"
+msgstr ""
+
+#: lvchange.c:297
+msgid "Failed to deactivate log LV after wiping failed"
+msgstr ""
+
+#: lvchange.c:303
+#, c-format
+msgid "Unable to deactivate log LV %s after wiping for resync"
+msgstr ""
+
+#: lvchange.c:316
+msgid "Failed to update metadata on disk."
+msgstr ""
+
+#: lvchange.c:321
+#, c-format
+msgid "Failed to reactivate %s after resync"
+msgstr ""
+
+#: lvchange.c:338
 #, c-format
 msgid "Allocation policy of logical volume \"%s\" is already %s"
 msgstr ""
 
-#: lvchange.c:165
+#: lvchange.c:347
 #, c-format
 msgid "Setting contiguous allocation policy for \"%s\" to %s"
 msgstr ""
 
-#: lvchange.c:201
+#: lvchange.c:383
 #, c-format
 msgid "Read ahead is already %u for \"%s\""
 msgstr ""
 
-#: lvchange.c:208
+#: lvchange.c:390
 #, c-format
 msgid "Setting read ahead to %u for \"%s\""
 msgstr ""
 
-#: lvchange.c:247
+#: lvchange.c:429
 #, c-format
 msgid "Minor number is already not persistent for \"%s\""
 msgstr ""
 
-#: lvchange.c:254
+#: lvchange.c:436
 #, c-format
 msgid "Disabling persistent device number for \"%s\""
 msgstr ""
 
-#: lvchange.c:258
+#: lvchange.c:440
 msgid "Minor number must be specified with -My"
 msgstr ""
 
-#: lvchange.c:262
+#: lvchange.c:444
 msgid "Major number must be specified with -My"
 msgstr ""
 
-#: lvchange.c:270
+#: lvchange.c:453
 #, c-format
 msgid "%s device number not changed."
 msgstr ""
 
-#: lvchange.c:276
+#: lvchange.c:457
 #, c-format
 msgid "Ensuring %s is inactive."
 msgstr ""
 
-#: lvchange.c:278
+#: lvchange.c:459
 #, c-format
 msgid "%s: deactivation failed"
 msgstr ""
 
-#: lvchange.c:284
+#: lvchange.c:465
 #, c-format
 msgid "Setting persistent device number to (%d, %d) for \"%s\""
 msgstr ""
 
-#: lvchange.c:287
+#: lvchange.c:484
 #, c-format
 msgid "Re-activating logical volume \"%s\""
 msgstr ""
 
-#: lvchange.c:290
+#: lvchange.c:486
 #, c-format
 msgid "%s: reactivation failed"
 msgstr ""
 
-#: lvchange.c:330 lvcreate.c:682 pvchange.c:49 vgchange.c:322 vgcreate.c:111
+#: lvchange.c:500 lvcreate.c:680 pvchange.c:49 vgchange.c:440 vgcreate.c:107
 msgid "Failed to get tag"
 msgstr ""
 
-#: lvchange.c:335
+#: lvchange.c:505
 #, c-format
 msgid "Logical volume %s/%s does not support tags"
 msgstr ""
 
-#: lvchange.c:342 lvcreate.c:693
+#: lvchange.c:512 lvcreate.c:746
 #, c-format
 msgid "Failed to add tag %s to %s/%s"
 msgstr ""
 
-#: lvchange.c:348
+#: lvchange.c:518
 #, c-format
 msgid "Failed to remove tag %s from %s/%s"
 msgstr ""
 
-#: lvchange.c:381
+#: lvchange.c:551
 #, c-format
 msgid "Only -a permitted with read-only volume group \"%s\""
 msgstr ""
 
-#: lvchange.c:390
+#: lvchange.c:560
 #, c-format
 msgid "Can't change logical volume \"%s\" under snapshot"
 msgstr ""
 
-#: lvchange.c:396
+#: lvchange.c:566
 #, c-format
 msgid "Can't change snapshot logical volume \"%s\""
 msgstr ""
 
-#: lvchange.c:402
+#: lvchange.c:572
 #, c-format
 msgid "Unable to change pvmove LV %s"
 msgstr ""
 
-#: lvchange.c:404
+#: lvchange.c:574
 msgid "Use 'pvmove --abort' to abandon a pvmove"
 msgstr ""
 
-#: lvchange.c:409
+#: lvchange.c:579
 #, c-format
 msgid "Unable to change mirror log LV %s directly"
 msgstr ""
 
-#: lvchange.c:414
+#: lvchange.c:584
 #, c-format
 msgid "Unable to change mirror image LV %s directly"
 msgstr ""
 
-#: lvchange.c:420
+#: lvchange.c:590
 #, c-format
 msgid "Unable to change internal LV %s directly"
 msgstr ""
 
-#: lvchange.c:474
+#: lvchange.c:648
 #, c-format
 msgid "Logical volume \"%s\" changed"
 msgstr ""
 
-#: lvchange.c:496
+#: lvchange.c:683
 msgid ""
-"One or more of -a, -C, -j, -m, -M, -p, -r, --refresh, --alloc, --addtag or --"
-"deltag required"
+"Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, "
+"--addtag, --deltag or --monitor"
 msgstr ""
 
-#: lvchange.c:506
+#: lvchange.c:694
 msgid "Only -a permitted with --ignorelockingfailure"
 msgstr ""
 
-#: lvchange.c:511 lvconvert.c:172
+#: lvchange.c:699
 msgid "Please give logical volume path(s)"
 msgstr ""
 
-#: lvchange.c:517
+#: lvchange.c:705
 msgid "--major and --minor require -My"
 msgstr ""
 
-#: lvchange.c:522
+#: lvchange.c:710
 msgid "Only give one logical volume when specifying minor"
 msgstr ""
 
-#: lvchange.c:527
+#: lvchange.c:715
 msgid "Only one of --alloc and --contiguous permitted"
 msgstr ""
 
-#: lvconvert.c:37
-#, c-format
-msgid "Logical volume %s is already not mirrored."
+#: lvconvert.c:50 lvcreate.c:69
+msgid "Please specify a logical volume to act as the snapshot origin."
 msgstr ""
 
-#: lvconvert.c:49
-#, c-format
-msgid "Logical volume %s has multiple mirror segments."
+#: lvconvert.c:58 lvcreate.c:77
+msgid "The origin name should include the volume group."
 msgstr ""
 
-#: lvconvert.c:57
-#, c-format
-msgid "Logical volume %s already has %u mirror(s)."
+#: lvconvert.c:69
+msgid "Please provide logical volume path"
 msgstr ""
 
-#: lvconvert.c:68 lvconvert.c:82
-msgid "Adding mirror images is not supported yet."
+#: lvconvert.c:79 lvrename.c:38
+#, c-format
+msgid "Please use a single volume group name (\"%s\" or \"%s\")"
 msgstr ""
 
-#: lvconvert.c:107
-#, c-format
-msgid "Updating \"%s\" in kernel"
+#: lvconvert.c:88 lvrename.c:52
+msgid "Please provide a valid volume group name"
 msgstr ""
 
-#: lvconvert.c:114
-#, c-format
-msgid "Logical volume %s converted."
+#: lvconvert.c:110
+msgid "Exactly one of --mirrors or --snapshot arguments required."
 msgstr ""
 
-#: lvconvert.c:125
-#, c-format
-msgid "Cannot convert locked LV %s"
+#: lvconvert.c:129
+msgid "--regionsize is only available with mirrors"
 msgstr ""
 
-#: lvconvert.c:130
-#, c-format
-msgid "Can't convert logical volume \"%s\" under snapshot"
+#: lvconvert.c:134 lvcreate.c:336
+msgid "Negative chunk size is invalid"
 msgstr ""
 
-#: lvconvert.c:136
-#, c-format
-msgid "Can't convert snapshot logical volume \"%s\""
+#: lvconvert.c:140 lvcreate.c:342
+msgid "Chunk size must be a power of 2 in the range 4K to 512K"
 msgstr ""
 
-#: lvconvert.c:142
+#: lvconvert.c:144 lvcreate.c:346
 #, c-format
-msgid "Unable to convert pvmove LV %s"
+msgid "Setting chunksize to %d sectors."
 msgstr ""
 
-#: lvconvert.c:167
-msgid "--mirrors argument required"
+#: lvconvert.c:156
+msgid "--chunksize is only available with snapshots"
 msgstr ""
 
-#: lvconvert.c:182 lvrename.c:54
-msgid "Please provide a valid volume group name"
+#: lvconvert.c:162
+msgid "--zero is only available with snapshots"
 msgstr ""
 
-#: lvconvert.c:189 lvrename.c:102 vgrename.c:65
-#, c-format
-msgid "Checking for existing volume group \"%s\""
+#: lvconvert.c:174 lvcreate.c:253
+msgid "Negative regionsize is invalid"
 msgstr ""
 
-#: lvconvert.c:192 lvcreate.c:809 lvrename.c:105 lvresize.c:566 pvchange.c:59
-#: pvmove.c:61 vgcreate.c:144 vgextend.c:47 vgmerge.c:33 vgmerge.c:57
-#: vgreduce.c:265 vgrename.c:68 vgrename.c:102 vgsplit.c:189 vgsplit.c:213
-#, c-format
-msgid "Can't get lock for %s"
+#: lvconvert.c:184 lvcreate.c:262
+msgid "Negative regionsize in configuration file is invalid"
 msgstr ""
 
-#: lvconvert.c:197 lvcreate.c:438 lvrename.c:110 pvmove.c:66 vgdisplay.c:24
-#: vgmerge.c:38 vgmerge.c:64 vgreduce.c:271 vgrename.c:73 vgsplit.c:194
+#: lvconvert.c:192 lvcreate.c:276
 #, c-format
-msgid "Volume group \"%s\" doesn't exist"
+msgid "Region size (%u) must be a multiple of machine memory page size (%d)"
 msgstr ""
 
-#: lvconvert.c:202 lvcreate.c:443 lvrename.c:115 metadata/metadata.c:1166
-#: polldaemon.c:200 pvchange.c:72 pvmove.c:72 toollib.c:42 vgchange.c:415
-#: vgck.c:32 vgconvert.c:54 vgextend.c:57 vgmerge.c:44 vgmerge.c:69
-#: vgreduce.c:321 vgremove.c:35 vgrename.c:80 vgsplit.c:200
+#: lvconvert.c:200 lvcreate.c:270
 #, c-format
-msgid "Volume group \"%s\" is exported"
+msgid "Region size (%u) must be a power of 2"
 msgstr ""
 
-#: lvconvert.c:207 lvcreate.c:448 lvremove.c:27 lvrename.c:120 pvchange.c:78
-#: pvmove.c:78 vgchange.c:410 vgconvert.c:49 vgexport.c:38 vgextend.c:62
-#: vgmerge.c:50 vgmerge.c:74 vgreduce.c:327 vgrename.c:86 vgsplit.c:206
-#, c-format
-msgid "Volume group \"%s\" is read-only"
+#: lvconvert.c:206 lvcreate.c:283
+msgid "Non-zero region size must be supplied."
 msgstr ""
 
-#: lvconvert.c:212
+#: lvconvert.c:216 lvcreate.c:390 metadata/mirror.c:566
 #, c-format
-msgid "Logical volume \"%s\" not found in volume group \"%s\""
-msgstr ""
-
-#: lvcreate.c:65
-msgid "Please specify a logical volume to act as the snapshot origin."
-msgstr ""
-
-#: lvcreate.c:73
-msgid "The origin name should include the volume group."
+msgid "%s: Required device-mapper target(s) not detected in your kernel"
 msgstr ""
 
-#: lvcreate.c:89 lvresize.c:102
-msgid "Please provide a volume group name"
+#: lvconvert.c:249
+#, c-format
+msgid "Logical volume %s only has %u mirrors."
 msgstr ""
 
-#: lvcreate.c:108
-msgid "Volume group name expected (no slash)"
+#: lvconvert.c:259
+msgid "Mirror log region size cannot be changed on an existing mirror."
 msgstr ""
 
-#: lvcreate.c:123
+#: lvconvert.c:266
 #, c-format
-msgid "Inconsistent volume group names given: \"%s\" and \"%s\""
+msgid "Logical volume %s is already not mirrored."
 msgstr ""
 
-#: lvcreate.c:146
+#: lvconvert.c:277
 #, c-format
-msgid "Logical volume name \"%s\" is invalid"
+msgid "Logical volume %s has multiple mirror segments."
 msgstr ""
 
-#: lvcreate.c:159 lvresize.c:64
-msgid "Please specify either size or extents (not both)"
+#: lvconvert.c:287 lvconvert.c:320
+msgid "Unable to determine mirror sync status."
 msgstr ""
 
-#: lvcreate.c:165
-msgid "Negative number of extents is invalid"
+#: lvconvert.c:311 lvconvert.c:389 lvcreate.c:721
+msgid "Failed to create mirror log."
 msgstr ""
 
-#: lvcreate.c:174
-msgid "Negative size is invalid"
+#: lvconvert.c:335
+#, c-format
+msgid "Logical volume %s already has %u mirror(s)."
 msgstr ""
 
-#: lvcreate.c:191
-msgid "Negative stripesize is invalid"
+#: lvconvert.c:346
+msgid "Adding mirror images is not supported yet."
 msgstr ""
 
-#: lvcreate.c:198
-msgid "Ignoring stripesize argument with single stripe"
+#: lvconvert.c:363
+msgid "Mirrors of striped volumes are not yet supported."
 msgstr ""
 
-#: lvcreate.c:206 lvresize.c:287
+#: lvconvert.c:419 metadata/mirror.c:237
 #, c-format
-msgid "Using default stripesize %dKB"
+msgid "Updating \"%s\" in kernel"
 msgstr ""
 
-#: lvcreate.c:210
+#: lvconvert.c:426
 #, c-format
-msgid "Too few physical volumes on command line for %d-way striping"
+msgid "Logical volume %s converted."
 msgstr ""
 
-#: lvcreate.c:216
+#: lvconvert.c:438 lvcreate.c:608
 #, c-format
-msgid "Number of stripes (%d) must be between %d and %d"
+msgid "Couldn't find origin volume '%s'."
 msgstr ""
 
-#: lvcreate.c:224
+#: lvconvert.c:443
 #, c-format
-msgid "Invalid stripe size %d"
+msgid "Unable to create a snapshot of a %s LV."
 msgstr ""
 
-#: lvcreate.c:238
+#: lvconvert.c:450 lvcreate.c:799
 #, c-format
-msgid "Too few physical volumes on command line for %d-way mirroring"
+msgid "WARNING: \"%s\" not zeroed"
 msgstr ""
 
-#: lvcreate.c:245
-msgid "Negative regionsize is invalid"
+#: lvconvert.c:452
+msgid "Aborting. Failed to wipe snapshot exception store."
 msgstr ""
 
-#: lvcreate.c:255
+#: lvconvert.c:458
 #, c-format
-msgid "Region size (%u) must be a power of 2"
+msgid "Couldn't deactivate LV %s."
 msgstr ""
 
-#: lvcreate.c:279
-msgid "Redundant stripes argument: default is 1"
+#: lvconvert.c:464 lvcreate.c:812
+msgid "Couldn't create snapshot."
 msgstr ""
 
-#: lvcreate.c:293
-msgid "Redundant mirrors argument: default is 0"
+#: lvconvert.c:475 lvcreate.c:821
+#, c-format
+msgid "Failed to suspend origin %s"
 msgstr ""
 
-#: lvcreate.c:298
-msgid "-Z is incompatible with snapshots"
+#: lvconvert.c:484 lvcreate.c:830
+#, c-format
+msgid "Problem reactivating origin %s"
 msgstr ""
 
-#: lvcreate.c:302
-msgid "Negative chunk size is invalid"
+#: lvconvert.c:488
+#, c-format
+msgid "Logical volume %s converted to snapshot."
 msgstr ""
 
-#: lvcreate.c:306
+#: lvconvert.c:499
 #, c-format
-msgid "Setting chunksize to %d sectors."
+msgid "Cannot convert locked LV %s"
 msgstr ""
 
-#: lvcreate.c:314
-msgid "-c is only available with snapshots"
+#: lvconvert.c:504
+#, c-format
+msgid "Can't convert logical volume \"%s\" under snapshot"
 msgstr ""
 
-#: lvcreate.c:321
-msgid "mirrors and snapshots are currently incompatible"
+#: lvconvert.c:510
+#, c-format
+msgid "Can't convert snapshot logical volume \"%s\""
 msgstr ""
 
-#: lvcreate.c:327
-msgid "mirrors and stripes are currently incompatible"
+#: lvconvert.c:516
+#, c-format
+msgid "Unable to convert pvmove LV %s"
 msgstr ""
 
-#: lvcreate.c:340 metadata/mirror.c:192
+#: lvconvert.c:548 lvrename.c:100 vgrename.c:62
 #, c-format
-msgid "%s: Required device-mapper target(s) not detected in your kernel"
+msgid "Checking for existing volume group \"%s\""
 msgstr ""
 
-#: lvcreate.c:368
-msgid "Conflicting contiguous and alloc arguments"
+#: lvconvert.c:551 lvcreate.c:863 lvrename.c:103 lvresize.c:613 pvchange.c:59
+#: pvmove.c:59 pvresize.c:69 vgcreate.c:140 vgextend.c:53 vgmerge.c:34
+#: vgmerge.c:65 vgreduce.c:476 vgrename.c:94 vgrename.c:133 vgsplit.c:240
+#: vgsplit.c:277
+#, c-format
+msgid "Can't get lock for %s"
 msgstr ""
 
-#: lvcreate.c:393
-msgid "Please specify minor number with --minor when using -My"
+#: lvconvert.c:556 lvcreate.c:492 lvrename.c:108 pvmove.c:64 vgdisplay.c:24
+#: vgmerge.c:39 vgmerge.c:72 vgreduce.c:482 vgsplit.c:245
+#, c-format
+msgid "Volume group \"%s\" doesn't exist"
 msgstr ""
 
-#: lvcreate.c:398
-msgid "Please specify major number with --major when using -My"
+#: lvconvert.c:562 lvcreate.c:498 lvrename.c:114 lvresize.c:146 pvchange.c:72
+#: pvdisplay.c:41 pvmove.c:71 pvresize.c:83 reporter.c:76 reporter.c:124
+#: toollib.c:363 toollib.c:383 toollib.c:490 toollib.c:741 vgextend.c:64
+#: vgmerge.c:46 vgmerge.c:78 vgreduce.c:489 vgreduce.c:511 vgrename.c:107
+#: vgsplit.c:252
+#, c-format
+msgid "Skipping clustered volume group %s"
 msgstr ""
 
-#: lvcreate.c:404
-msgid "--major and --minor incompatible with -Mn"
+#: lvconvert.c:567 lvcreate.c:503 lvrename.c:119 metadata/metadata.c:1377
+#: polldaemon.c:195 pvchange.c:78 pvmove.c:76 pvresize.c:89 toollib.c:163
+#: vgchange.c:534 vgck.c:34 vgconvert.c:54 vgextend.c:69 vgmerge.c:52
+#: vgmerge.c:83 vgreduce.c:541 vgremove.c:35 vgrename.c:113 vgsplit.c:258
+#, c-format
+msgid "Volume group \"%s\" is exported"
 msgstr ""
 
-#: lvcreate.c:435 pvmove.c:300 toollib.c:350 vgreduce.c:263
+#: lvconvert.c:572 lvcreate.c:508 lvremove.c:28 lvrename.c:124 pvchange.c:84
+#: pvmove.c:82 pvresize.c:95 vgchange.c:529 vgconvert.c:49 vgexport.c:42
+#: vgextend.c:74 vgmerge.c:58 vgmerge.c:88 vgreduce.c:547 vgrename.c:117
+#: vgsplit.c:270
 #, c-format
-msgid "Finding volume group \"%s\""
+msgid "Volume group \"%s\" is read-only"
 msgstr ""
 
-#: lvcreate.c:453 lvrename.c:125
+#: lvconvert.c:577
 #, c-format
-msgid "Logical volume \"%s\" already exists in volume group \"%s\""
+msgid "Logical volume \"%s\" not found in volume group \"%s\""
 msgstr ""
 
-#: lvcreate.c:459
-msgid "Metadata does not support mirroring."
+#: lvcreate.c:93 lvresize.c:105
+msgid "Please provide a volume group name"
 msgstr ""
 
-#: lvcreate.c:476
-#, c-format
-msgid "Setting stripe size %d KB to physical extent size %u KB"
+#: lvcreate.c:100
+msgid "Volume group name expected (no slash)"
 msgstr ""
 
-#: lvcreate.c:489 lvresize.c:206
+#: lvcreate.c:115
 #, c-format
-msgid "Rounding up size to full physical extent %s"
+msgid "Inconsistent volume group names given: \"%s\" and \"%s\""
 msgstr ""
 
-#: lvcreate.c:497
+#: lvcreate.c:138
 #, c-format
-msgid "Rounding size (%d extents) up to stripe boundary size (%d extents)"
+msgid "Logical volume name \"%s\" is invalid"
 msgstr ""
 
-#: lvcreate.c:505
-msgid "Can't create snapshot without using device-mapper kernel driver"
+#: lvcreate.c:151 lvresize.c:65
+msgid "Please specify either size or extents (not both)"
 msgstr ""
 
-#: lvcreate.c:510
-#, c-format
-msgid "Couldn't find origin volume '%s'."
+#: lvcreate.c:157
+msgid "Negative number of extents is invalid"
 msgstr ""
 
-#: lvcreate.c:515
-msgid "Snapshots of snapshots are not supported yet."
+#: lvcreate.c:167
+msgid "Negative size is invalid"
 msgstr ""
 
-#: lvcreate.c:520
-msgid "Snapshots of locked devices are not supported yet"
+#: lvcreate.c:189
+msgid "Negative stripesize is invalid"
 msgstr ""
 
-#: lvcreate.c:529
+#: lvcreate.c:194 lvresize.c:192
 #, c-format
-msgid "Unable to create logical volume %s with no extents"
+msgid "Stripe size cannot be larger than %s"
 msgstr ""
 
-#: lvcreate.c:536
+#: lvcreate.c:202
+msgid "Ignoring stripesize argument with single stripe"
+msgstr ""
+
+#: lvcreate.c:210 lvresize.c:330
 #, c-format
-msgid "Insufficient free extents (%u) in volume group %s: %u required"
+msgid "Using default stripesize %s"
 msgstr ""
 
-#: lvcreate.c:542
+#: lvcreate.c:215
 #, c-format
-msgid "Number of stripes (%u) must not exceed number of physical volumes (%d)"
+msgid "Too few physical volumes on command line for %d-way striping"
 msgstr ""
 
-#: lvcreate.c:549
-msgid "Can't create mirror without using device-mapper kernel driver."
+#: lvcreate.c:221
+#, c-format
+msgid "Number of stripes (%d) must be between %d and %d"
 msgstr ""
 
-#: lvcreate.c:568
-msgid "Failed to generate LV name."
+#: lvcreate.c:229 lvresize.c:407
+#, c-format
+msgid "Invalid stripe size %s"
 msgstr ""
 
-#: lvcreate.c:580 mirror/mirrored.c:218
+#: lvcreate.c:246
 #, c-format
-msgid "Using reduced mirror region size of %u sectors"
+msgid "Too few physical volumes on command line for %d-way mirroring"
 msgstr ""
 
-#: lvcreate.c:588 lvcreate.c:594 lvcreate.c:602
-msgid "log_name allocation failed. Remove new LV and retry."
+#: lvcreate.c:309
+msgid "Redundant stripes argument: default is 1"
 msgstr ""
 
-#: lvcreate.c:641
-msgid "Aborting. Failed to activate mirror log. Remove new LVs and retry."
+#: lvcreate.c:323
+msgid "Redundant mirrors argument: default is 0"
 msgstr ""
 
-#: lvcreate.c:647
-msgid "Aborting. Failed to wipe mirror log. Remove new LV and retry."
+#: lvcreate.c:325 lvresize.c:180
+msgid "Mirrors argument may not be negative"
 msgstr ""
 
-#: lvcreate.c:653
-msgid "Aborting. Failed to deactivate mirror log. Remove new LV and retry."
+#: lvcreate.c:332
+msgid "-Z is incompatible with snapshots"
 msgstr ""
 
-#: lvcreate.c:668
-msgid "Setting read ahead sectors"
+#: lvcreate.c:354
+msgid "-c is only available with snapshots"
+msgstr ""
+
+#: lvcreate.c:361
+msgid "mirrors and snapshots are currently incompatible"
+msgstr ""
+
+#: lvcreate.c:367
+msgid "mirrors and stripes are currently incompatible"
+msgstr ""
+
+#: lvcreate.c:378
+msgid "--corelog is only available with mirrors"
+msgstr ""
+
+#: lvcreate.c:383
+msgid "--nosync is only available with mirrors"
+msgstr ""
+
+#: lvcreate.c:419
+msgid "Conflicting contiguous and alloc arguments"
+msgstr ""
+
+#: lvcreate.c:448
+msgid "Please specify minor number with --minor when using -My"
+msgstr ""
+
+#: lvcreate.c:453
+msgid "Please specify major number with --major when using -My"
+msgstr ""
+
+#: lvcreate.c:459
+msgid "--major and --minor incompatible with -Mn"
 msgstr ""
 
-#: lvcreate.c:676
+#: lvcreate.c:489 pvmove.c:305 toollib.c:481 vgreduce.c:474
 #, c-format
-msgid "Setting device number to (%d, %d)"
+msgid "Finding volume group \"%s\""
 msgstr ""
 
-#: lvcreate.c:687 vgchange.c:327
+#: lvcreate.c:513 lvrename.c:129
 #, c-format
-msgid "Volume group %s does not support tags"
+msgid "Logical volume \"%s\" already exists in volume group \"%s\""
 msgstr ""
 
-#: lvcreate.c:731
-msgid ""
-"Aborting. Failed to activate snapshot exception store. Remove new LV and "
-"retry."
+#: lvcreate.c:519
+msgid "Metadata does not support mirroring."
 msgstr ""
 
-#: lvcreate.c:734
-msgid "Failed to activate new LV."
+#: lvcreate.c:536
+#, c-format
+msgid "Reducing requested stripe size %s to maximum, physical extent size %s"
 msgstr ""
 
-#: lvcreate.c:741
-msgid ""
-"Aborting. Failed to wipe snapshot exception store. Remove new LV and retry."
+#: lvcreate.c:547
+#, c-format
+msgid "Stripe size may not exceed %s"
 msgstr ""
 
-#: lvcreate.c:746
+#: lvcreate.c:559 lvresize.c:237
 #, c-format
-msgid "WARNING: \"%s\" not zeroed"
+msgid "Rounding up size to full physical extent %s"
 msgstr ""
 
-#: lvcreate.c:755
-msgid "Couldn't deactivate new snapshot."
+#: lvcreate.c:564
+#, c-format
+msgid "Volume too large (%s) for extent size %s. Upper limit is %s."
 msgstr ""
 
-#: lvcreate.c:761
+#: lvcreate.c:583
 #, c-format
-msgid "Failed to suspend origin %s"
+msgid "Please express size as %%VG or %%FREE."
 msgstr ""
 
-#: lvcreate.c:767
-msgid "Couldn't create snapshot."
+#: lvcreate.c:590
+#, c-format
+msgid "Rounding size (%d extents) up to stripe boundary size (%d extents)"
+msgstr ""
+
+#: lvcreate.c:598
+msgid "Can't create snapshot without using device-mapper kernel driver"
+msgstr ""
+
+#: lvcreate.c:604
+msgid "Clustered snapshots are not yet supported."
+msgstr ""
+
+#: lvcreate.c:613
+msgid "Snapshots of snapshots are not supported yet."
+msgstr ""
+
+#: lvcreate.c:618
+msgid "Snapshots of locked devices are not supported yet"
+msgstr ""
+
+#: lvcreate.c:625
+msgid "Snapshots and mirrors may not yet be mixed."
+msgstr ""
+
+#: lvcreate.c:634
+msgid "Unable to create new logical volume with no extents"
 msgstr ""
 
-#: lvcreate.c:776
+#: lvcreate.c:640
 #, c-format
-msgid "Problem reactivating origin %s"
+msgid "Insufficient free extents (%u) in volume group %s: %u required"
+msgstr ""
+
+#: lvcreate.c:646
+#, c-format
+msgid "Number of stripes (%u) must not exceed number of physical volumes (%d)"
+msgstr ""
+
+#: lvcreate.c:653
+msgid "Can't create mirror without using device-mapper kernel driver."
+msgstr ""
+
+#: lvcreate.c:672
+msgid "Failed to generate LV name."
+msgstr ""
+
+#: lvcreate.c:685 vgchange.c:445
+#, c-format
+msgid "Volume group %s does not support tags"
+msgstr ""
+
+#: lvcreate.c:709
+msgid ""
+"WARNING: New mirror won't be synchronised. Don't read what you didn't write!"
+msgstr ""
+
+#: lvcreate.c:733
+msgid "Setting read ahead sectors"
+msgstr ""
+
+#: lvcreate.c:741
+#, c-format
+msgid "Setting device number to (%d, %d)"
+msgstr ""
+
+#: lvcreate.c:782
+msgid ""
+"Aborting. Failed to activate snapshot exception store. Remove new LV and "
+"retry."
+msgstr ""
+
+#: lvcreate.c:787
+msgid "Failed to activate new LV."
+msgstr ""
+
+#: lvcreate.c:794
+msgid ""
+"Aborting. Failed to wipe snapshot exception store. Remove new LV and retry."
 msgstr ""
 
-#: lvcreate.c:783
+#: lvcreate.c:837
 #, c-format
 msgid "Logical volume \"%s\" created"
 msgstr ""
 
-#: lvdisplay.c:39 lvdisplay.c:48 pvdisplay.c:62 pvdisplay.c:72 vgdisplay.c:67
+#: lvdisplay.c:39 lvdisplay.c:48 pvdisplay.c:89 pvdisplay.c:99 vgdisplay.c:67
 #: vgdisplay.c:76
 msgid "Incompatible options selected"
 msgstr ""
@@ -3799,27 +4171,27 @@
 msgid "Options -v and -c are incompatible"
 msgstr ""
 
-#: lvmchange.c:20
+#: lvmchange.c:21
 msgid "With LVM2 and the device mapper, this program is obsolete."
 msgstr ""
 
-#: lvmcmdline.c:269
+#: lvmcmdline.c:289
 msgid "Minor number outside range 0-255"
 msgstr ""
 
-#: lvmcmdline.c:284
+#: lvmcmdline.c:304
 msgid "Major number outside range 0-255"
 msgstr ""
 
-#: lvmcmdline.c:373
+#: lvmcmdline.c:402
 msgid "Couldn't allocate memory."
 msgstr ""
 
-#: lvmcmdline.c:422
+#: lvmcmdline.c:451
 msgid "Out of memory."
 msgstr ""
 
-#: lvmcmdline.c:475
+#: lvmcmdline.c:504
 #, c-format
 msgid ""
 "%s: %s\n"
@@ -3827,150 +4199,142 @@
 "%s"
 msgstr ""
 
-#: lvmcmdline.c:569
+#: lvmcmdline.c:598
 msgid "Unrecognised option."
 msgstr ""
 
-#: lvmcmdline.c:575
+#: lvmcmdline.c:604
 #, c-format
 msgid "Option%s%c%s%s may not be repeated"
 msgstr ""
 
-#: lvmcmdline.c:584
+#: lvmcmdline.c:613
 msgid "Option requires argument."
 msgstr ""
 
-#: lvmcmdline.c:591
+#: lvmcmdline.c:620
 #, c-format
 msgid "Invalid argument %s"
 msgstr ""
 
-#: lvmcmdline.c:610
+#: lvmcmdline.c:639
 #, c-format
 msgid "%s and %s are synonyms.  Please only supply one."
 msgstr ""
 
-#: lvmcmdline.c:636
+#: lvmcmdline.c:667
 #, c-format
 msgid "LVM version:     %s"
 msgstr ""
 
-#: lvmcmdline.c:638
+#: lvmcmdline.c:669
 #, c-format
 msgid "Library version: %s"
 msgstr ""
 
-#: lvmcmdline.c:640
+#: lvmcmdline.c:671
 #, c-format
 msgid "Driver version:  %s"
 msgstr ""
 
-#: lvmcmdline.c:677
+#: lvmcmdline.c:706
 msgid "Partial mode. Incomplete volume groups will be activated read-only."
 msgstr ""
 
-#: lvmcmdline.c:727
+#: lvmcmdline.c:729
+msgid "--trustcache is incompatible with --all"
+msgstr ""
+
+#: lvmcmdline.c:733
+msgid ""
+"WARNING: Cache file of PVs will be trusted.  New devices holding PVs may get "
+"ignored."
+msgstr ""
+
+#: lvmcmdline.c:767
 msgid "Available lvm commands:"
 msgstr ""
 
-#: lvmcmdline.c:728
+#: lvmcmdline.c:768
 msgid "Use 'lvm help <command>' for more information"
 msgstr ""
 
-#: lvmcmdline.c:734
+#: lvmcmdline.c:774
 #, c-format
 msgid "%-16.16s%s"
 msgstr ""
 
-#: lvmcmdline.c:799
+#: lvmcmdline.c:794
+msgid "Failed to set overridden configuration entries."
+msgstr ""
+
+#: lvmcmdline.c:858
 msgid "Couldn't copy command line."
 msgstr ""
 
-#: lvmcmdline.c:812
+#: lvmcmdline.c:871
 #, c-format
 msgid "Parsing: %s"
 msgstr ""
 
-#: lvmcmdline.c:818
+#: lvmcmdline.c:877
 msgid "Error during parsing of command line."
 msgstr ""
 
-#: lvmcmdline.c:827
+#: lvmcmdline.c:890
 msgid "Updated config file invalid. Aborting."
 msgstr ""
 
-#: lvmcmdline.c:836
+#: lvmcmdline.c:899
 #, c-format
 msgid "Processing: %s"
 msgstr ""
 
-#: lvmcmdline.c:839
+#: lvmcmdline.c:902
 msgid "O_DIRECT will be used"
 msgstr ""
 
-#: lvmcmdline.c:852
+#: lvmcmdline.c:915
 #, c-format
 msgid "Locking type %d initialisation failed."
 msgstr ""
 
-#: lvmcmdline.c:864
+#: lvmcmdline.c:927
 msgid "Test mode: Wiping internal cache"
 msgstr ""
 
-#: lvmcmdline.c:994
-#, c-format
-msgid "Line too long (max 255) beginning: %s"
-msgstr ""
-
-#: lvmcmdline.c:1001
-#, c-format
-msgid "Too many arguments: %s"
-msgstr ""
-
-#: lvmcmdline.c:1133
-msgid "$HOME/.lvm_history: path too long"
-msgstr ""
-
-#: lvmcmdline.c:1148
+#: lvmcmdline.c:951
 #, c-format
-msgid "Couldn't read history from %s."
+msgid "Completed: %s"
 msgstr ""
 
-#: lvmcmdline.c:1163
+#: lvmcmdline.c:1073
 #, c-format
-msgid "Couldn't write history to %s."
-msgstr ""
-
-#: lvmcmdline.c:1196
-msgid "Too many arguments, sorry."
-msgstr ""
-
-#: lvmcmdline.c:1210
-msgid "Exiting."
+msgid "Line too long (max 255) beginning: %s"
 msgstr ""
 
-#: lvmcmdline.c:1216
+#: lvmcmdline.c:1080
 #, c-format
-msgid "No such command '%s'.  Try 'help'."
+msgid "Too many arguments: %s"
 msgstr ""
 
-#: lvmcmdline.c:1342
+#: lvmcmdline.c:1125
 msgid "Failed to create LVM1 tool pathname"
 msgstr ""
 
-#: lvmcmdline.c:1390
+#: lvmcmdline.c:1173
 msgid "Falling back to LVM1 tools, but no command specified."
 msgstr ""
 
-#: lvmcmdline.c:1406
+#: lvmcmdline.c:1189
 msgid "Please supply an LVM command."
 msgstr ""
 
-#: lvmcmdline.c:1420
+#: lvmcmdline.c:1203
 msgid "No such command.  Try 'help'."
 msgstr ""
 
-#: lvmdiskscan.c:38 lvmdiskscan.c:107
+#: lvmdiskscan.c:38 lvmdiskscan.c:108
 msgid "dev_iter_create failed"
 msgstr ""
 
@@ -3979,7 +4343,7 @@
 msgid "%-*s [%15s] %s"
 msgstr ""
 
-#: lvmdiskscan.c:83 lvmdiskscan.c:116
+#: lvmdiskscan.c:83 lvmdiskscan.c:117
 #, c-format
 msgid "Couldn't get size of \"%s\""
 msgstr ""
@@ -3989,476 +4353,552 @@
 msgid "dev_close on \"%s\" failed"
 msgstr ""
 
-#: lvmdiskscan.c:102
+#: lvmdiskscan.c:103
 msgid "WARNING: only considering LVM devices"
 msgstr ""
 
-#: lvmdiskscan.c:136
+#: lvmdiskscan.c:137
 #, c-format
 msgid "%d disk%s"
 msgstr ""
 
-#: lvmdiskscan.c:138
+#: lvmdiskscan.c:139
 #, c-format
 msgid "%d partition%s"
 msgstr ""
 
-#: lvmdiskscan.c:141
+#: lvmdiskscan.c:142
 #, c-format
 msgid "%d LVM physical volume whole disk%s"
 msgstr ""
 
-#: lvmdiskscan.c:143
+#: lvmdiskscan.c:144
 #, c-format
 msgid "%d LVM physical volume%s"
 msgstr ""
 
-#: lvremove.c:32
+#: lvremove.c:33
 #, c-format
 msgid "Can't remove logical volume \"%s\" under snapshot"
 msgstr ""
 
-#: lvremove.c:38
+#: lvremove.c:39
 #, c-format
 msgid "Can't remove logical volume %s used by a mirror"
 msgstr ""
 
-#: lvremove.c:44
+#: lvremove.c:45
 #, c-format
 msgid "Can't remove logical volume %s used as mirror log"
 msgstr ""
 
-#: lvremove.c:50
+#: lvremove.c:51
 #, c-format
 msgid "Can't remove locked LV %s"
 msgstr ""
 
-#: lvremove.c:58
+#: lvremove.c:59
 #, c-format
 msgid "Can't remove open logical volume \"%s\""
 msgstr ""
 
-#: lvremove.c:67
+#: lvremove.c:68
 #, c-format
 msgid "Logical volume \"%s\" not removed"
 msgstr ""
 
-#: lvremove.c:78
+#: lvremove.c:82
+#, c-format
+msgid "Can't get exclusive access to volume \"%s\""
+msgstr ""
+
+#: lvremove.c:90
 #, c-format
 msgid "Unable to deactivate logical volume \"%s\""
 msgstr ""
 
-#: lvremove.c:84
+#: lvremove.c:97
 #, c-format
 msgid "Removing snapshot %s"
 msgstr ""
 
-#: lvremove.c:91
+#: lvremove.c:104
 #, c-format
 msgid "Releasing logical volume \"%s\""
 msgstr ""
 
-#: lvremove.c:93
+#: lvremove.c:106
 #, c-format
 msgid "Error releasing logical volume \"%s\""
 msgstr ""
 
-#: lvremove.c:106
+#: lvremove.c:122
 #, c-format
-msgid "Logical volume \"%s\" successfully removed"
+msgid "Failed to refresh %s without snapshot."
 msgstr ""
 
-#: lvremove.c:113
-msgid "Please enter one or more logical volume paths"
+#: lvremove.c:124
+#, c-format
+msgid "Failed to resume %s."
 msgstr ""
 
-#: lvrename.c:40
+#: lvremove.c:127
 #, c-format
-msgid "Please use a single volume group name (\"%s\" or \"%s\")"
+msgid "Logical volume \"%s\" successfully removed"
+msgstr ""
+
+#: lvremove.c:134
+msgid "Please enter one or more logical volume paths"
 msgstr ""
 
-#: lvrename.c:49
+#: lvrename.c:47
 msgid "Old and new logical volume names required"
 msgstr ""
 
-#: lvrename.c:61
+#: lvrename.c:59
 #, c-format
 msgid "Logical volume names must have the same volume group (\"%s\" or \"%s\")"
 msgstr ""
 
-#: lvrename.c:76
+#: lvrename.c:74
+#, c-format
 msgid "New logical volume path exceeds maximum length of %zu!"
 msgstr ""
 
-#: lvrename.c:82
+#: lvrename.c:80
 msgid "New logical volume name may not be blank"
 msgstr ""
 
-#: lvrename.c:92
+#: lvrename.c:90
 #, c-format
 msgid "New logical volume name \"%s\" is invalid"
 msgstr ""
 
-#: lvrename.c:98
+#: lvrename.c:96
 msgid "Old and new logical volume names must differ"
 msgstr ""
 
-#: lvrename.c:131
+#: lvrename.c:135
 #, c-format
 msgid "Existing logical volume \"%s\" not found in volume group \"%s\""
 msgstr ""
 
-#: lvrename.c:139
+#: lvrename.c:143
 #, c-format
 msgid "Cannot rename locked LV %s"
 msgstr ""
 
-#: lvrename.c:149
+#: lvrename.c:150 lvrename.c:158
+#, c-format
+msgid "Mirrored LV, \"%s\" cannot be renamed: %s"
+msgstr ""
+
+#: lvrename.c:169
 msgid "Failed to allocate space for new name"
 msgstr ""
 
-#: lvrename.c:153 vgmerge.c:190 vgrename.c:134
+#: lvrename.c:173 vgmerge.c:223 vgrename.c:165
 msgid "Writing out updated volume group"
 msgstr ""
 
-#: lvrename.c:176
+#: lvrename.c:197
 #, c-format
 msgid "Renamed \"%s\" to \"%s\" in volume group \"%s\""
 msgstr ""
 
-#: lvresize.c:80
+#: lvresize.c:83
 msgid "Negative argument not permitted - use lvreduce"
 msgstr ""
 
-#: lvresize.c:85
+#: lvresize.c:88
 msgid "Positive sign not permitted - use lvextend"
 msgstr ""
 
-#: lvresize.c:93
+#: lvresize.c:96
 msgid "Please provide the logical volume name"
 msgstr ""
 
-#: lvresize.c:138
+#: lvresize.c:140
 #, c-format
 msgid "Volume group %s doesn't exist"
 msgstr ""
 
-#: lvresize.c:143
+#: lvresize.c:151
 #, c-format
 msgid "Volume group %s is exported"
 msgstr ""
 
-#: lvresize.c:148
+#: lvresize.c:156
 #, c-format
 msgid "Volume group %s is read-only"
 msgstr ""
 
-#: lvresize.c:154
+#: lvresize.c:162
 #, c-format
 msgid "Logical volume %s not found in volume group %s"
 msgstr ""
 
-#: lvresize.c:163
+#: lvresize.c:171
 msgid "Varied striping not supported. Ignoring."
 msgstr ""
 
-#: lvresize.c:170
+#: lvresize.c:178
 msgid "Mirrors not supported. Ignoring."
 msgstr ""
 
-#: lvresize.c:175
+#: lvresize.c:187
 msgid "Stripesize may not be negative."
 msgstr ""
 
-#: lvresize.c:182
+#: lvresize.c:198
 msgid "Varied stripesize not supported. Ignoring."
 msgstr ""
 
-#: lvresize.c:184
+#: lvresize.c:200
+#, c-format
+msgid "Reducing stripe size %s to maximum, physical extent size %s"
+msgstr ""
+
+#: lvresize.c:211
 msgid "Mirrors and striping cannot be combined yet."
 msgstr ""
 
-#: lvresize.c:192
+#: lvresize.c:215
+msgid "Stripe size must be power of 2"
+msgstr ""
+
+#: lvresize.c:223
 #, c-format
 msgid "Can't resize locked LV %s"
 msgstr ""
 
-#: lvresize.c:219
+#: lvresize.c:263
 #, c-format
 msgid "Unable to reduce %s below 1 extent"
 msgstr ""
 
-#: lvresize.c:228
+#: lvresize.c:272
 msgid "New size of 0 not permitted"
 msgstr ""
 
-#: lvresize.c:233 lvresize.c:365
+#: lvresize.c:277 lvresize.c:414
 #, c-format
 msgid "New size (%d extents) matches existing size (%d extents)"
 msgstr ""
 
-#: lvresize.c:248
+#: lvresize.c:291
 #, c-format
 msgid "VolumeType does not match (%s)"
 msgstr ""
 
-#: lvresize.c:265
+#: lvresize.c:308
 msgid "Please specify number of stripes (-i) and stripesize (-I)"
 msgstr ""
 
-#: lvresize.c:279
+#: lvresize.c:322
 #, c-format
-msgid "Using stripesize of last segment %dKB"
+msgid "Using stripesize of last segment %s"
 msgstr ""
 
-#: lvresize.c:303
+#: lvresize.c:346
 #, c-format
 msgid "Extending %u mirror images."
 msgstr ""
 
-#: lvresize.c:309
+#: lvresize.c:352
 msgid "Cannot vary number of mirrors in LV yet."
 msgstr ""
 
-#: lvresize.c:319
+#: lvresize.c:362
 msgid "Ignoring stripes, stripesize and mirrors arguments when reducing"
 msgstr ""
 
-#: lvresize.c:348
+#: lvresize.c:391
 msgid "Stripesize for striped segment should not be 0!"
 msgstr ""
 
-#: lvresize.c:357
+#: lvresize.c:400
 #, c-format
 msgid ""
 "Rounding size (%d extents) down to stripe boundary size for segment (%d "
 "extents)"
 msgstr ""
 
-#: lvresize.c:372
+#: lvresize.c:421
 #, c-format
 msgid "New size given (%d extents) not larger than existing size (%d extents)"
 msgstr ""
 
-#: lvresize.c:382
+#: lvresize.c:431
 #, c-format
 msgid "New size given (%d extents) not less than existing size (%d extents)"
 msgstr ""
 
-#: lvresize.c:392
+#: lvresize.c:441
 msgid "Mirrors cannot be resized while active yet."
 msgstr ""
 
-#: lvresize.c:398
+#: lvresize.c:447
 msgid "Snapshot origin volumes cannot be reduced in size yet."
 msgstr ""
 
-#: lvresize.c:406
+#: lvresize.c:455
 msgid ""
 "Snapshot origin volumes can be resized only while inactive: try lvchange -an"
 msgstr ""
 
-#: lvresize.c:414
+#: lvresize.c:463
 msgid "Ignoring PVs on command line when reducing"
 msgstr ""
 
-#: lvresize.c:425
+#: lvresize.c:474
 msgid "lv_info failed: aborting"
 msgstr ""
 
-#: lvresize.c:430
+#: lvresize.c:479
 #, c-format
 msgid "Logical volume %s must be activated before resizing filesystem"
 msgstr ""
 
-#: lvresize.c:436
+#: lvresize.c:485
 #, c-format
 msgid "WARNING: Reducing active%s logical volume to %s"
 msgstr ""
 
-#: lvresize.c:442
+#: lvresize.c:490
 msgid "THIS MAY DESTROY YOUR DATA (filesystem etc.)"
 msgstr ""
 
-#: lvresize.c:449
+#: lvresize.c:497
 #, c-format
 msgid "Logical volume %s NOT reduced"
 msgstr ""
 
-#: lvresize.c:460
+#: lvresize.c:508
 #, c-format
 msgid "Couldn't create LV path for %s"
 msgstr ""
 
-#: lvresize.c:468
+#: lvresize.c:516
 msgid "Couldn't generate new LV size string"
 msgstr ""
 
-#: lvresize.c:492
+#: lvresize.c:540
 #, c-format
 msgid "%sing logical volume %s to %s"
 msgstr ""
 
-#: lvresize.c:542
+#: lvresize.c:589
 #, c-format
 msgid "Logical volume %s successfully resized"
 msgstr ""
 
-#: lvresize.c:564
+#: lvresize.c:611
 #, c-format
 msgid "Finding volume group %s"
 msgstr ""
 
-#: lvscan.c:40
+#: lvscan.c:64
 #, c-format
 msgid "%s%s '%s%s/%s' [%s] %s"
 msgstr ""
 
-#: lvscan.c:55
+#: lvscan.c:79
 msgid "No additional command line arguments allowed"
 msgstr ""
 
-#: metadata/lv_manip.c:78
+#: metadata/lv_manip.c:96
 msgid "alloc_lv_segment: Missing segtype."
 msgstr ""
 
-#: metadata/lv_manip.c:110
+#: metadata/lv_manip.c:131
 msgid "Failed to find snapshot segtype"
 msgstr ""
 
-#: metadata/lv_manip.c:118
+#: metadata/lv_manip.c:139
 msgid "Couldn't allocate new snapshot segment."
 msgstr ""
 
-#: metadata/lv_manip.c:236
+#: metadata/lv_manip.c:280
 #, c-format
 msgid "Segment extent reduction %unot divisible by #stripes %u"
 msgstr ""
 
-#: metadata/lv_manip.c:381
+#: metadata/lv_manip.c:445
 msgid "Striped mirrors are not supported yet"
 msgstr ""
 
-#: metadata/lv_manip.c:386
+#: metadata/lv_manip.c:450
 msgid "Can't mix striping or mirroring with creation of a mirrored PV yet"
 msgstr ""
 
-#: metadata/lv_manip.c:392
+#: metadata/lv_manip.c:456
 msgid "Can't mix striping or pvmove with a mirror log yet."
 msgstr ""
 
-#: metadata/lv_manip.c:407
+#: metadata/lv_manip.c:471
 msgid "allocation handle allocation failed"
 msgstr ""
 
-#: metadata/lv_manip.c:415
+#: metadata/lv_manip.c:481
 msgid "allocation pool creation failed"
 msgstr ""
 
-#: metadata/lv_manip.c:462
+#: metadata/lv_manip.c:516 report/report.c:92 report/report.c:152
+msgid "dm_pool_begin_object failed"
+msgstr ""
+
+#: metadata/lv_manip.c:523 metadata/lv_manip.c:528 metadata/lv_manip.c:535
+#: report/report.c:112 report/report.c:123 report/report.c:129
+#: report/report.c:135 report/report.c:159 report/report.c:165
+msgid "dm_pool_grow_object failed"
+msgstr ""
+
+#: metadata/lv_manip.c:541
+#, c-format
+msgid "Parallel PVs at LE %u length %u: %s"
+msgstr ""
+
+#: metadata/lv_manip.c:574
 msgid "Couldn't allocate new LV segment."
 msgstr ""
 
-#: metadata/lv_manip.c:542
+#: metadata/lv_manip.c:654
 msgid "alloced_area allocation failed"
 msgstr ""
 
-#: metadata/lv_manip.c:754
+#: metadata/lv_manip.c:705
+#, c-format
+msgid "Failed to find segment for %s extent %u"
+msgstr ""
+
+#: metadata/lv_manip.c:907
+#, c-format
+msgid "Insufficient free space: %u extents needed, but only %u available"
+msgstr ""
+
+#: metadata/lv_manip.c:1081
 msgid "_allocate called with no work to do!"
 msgstr ""
 
-#: metadata/lv_manip.c:775
+#: metadata/lv_manip.c:1105
 msgid "Not enough PVs with free space available for parallel allocation."
 msgstr ""
 
-#: metadata/lv_manip.c:777
+#: metadata/lv_manip.c:1107
 msgid "Consider --alloc anywhere if desperate."
 msgstr ""
 
-#: metadata/lv_manip.c:785
+#: metadata/lv_manip.c:1120
 msgid "Couldn't allocate areas array."
 msgstr ""
 
-#: metadata/lv_manip.c:822
+#: metadata/lv_manip.c:1137
 #, c-format
 msgid ""
 "Insufficient suitable %sallocatable extents for logical volume %s: %u more "
 "required"
 msgstr ""
 
-#: metadata/lv_manip.c:846
+#: metadata/lv_manip.c:1147
+#, c-format
+msgid "Insufficient extents for log allocation for logical volume %s."
+msgstr ""
+
+#: metadata/lv_manip.c:1168
 msgid "Couldn't allocate new zero segment."
 msgstr ""
 
-#: metadata/lv_manip.c:878
+#: metadata/lv_manip.c:1201
 msgid "allocate_extents does not handle virtual segments"
 msgstr ""
 
-#: metadata/lv_manip.c:884
+#: metadata/lv_manip.c:1207
 #, c-format
 msgid "Metadata format (%s) does not support required LV segment type (%s)."
 msgstr ""
 
-#: metadata/lv_manip.c:887
+#: metadata/lv_manip.c:1210
 msgid "Consider changing the metadata format by running vgconvert."
 msgstr ""
 
-#: metadata/lv_manip.c:928
+#: metadata/lv_manip.c:1251
 msgid "Missing segtype in lv_add_segment()."
 msgstr ""
 
-#: metadata/lv_manip.c:933
+#: metadata/lv_manip.c:1256
 msgid "lv_add_segment cannot handle virtual segments"
 msgstr ""
 
-#: metadata/lv_manip.c:947
+#: metadata/lv_manip.c:1270
 msgid "Couldn't merge segments after extending logical volume."
 msgstr ""
 
-#: metadata/lv_manip.c:969
+#: metadata/lv_manip.c:1292
 msgid "Log segments can only be added to an empty LV"
 msgstr ""
 
-#: metadata/lv_manip.c:978
+#: metadata/lv_manip.c:1301
 msgid "Couldn't allocate new mirror log segment."
 msgstr ""
 
-#: metadata/lv_manip.c:1016
+#: metadata/lv_manip.c:1339
 #, c-format
 msgid "Log LV %s is empty."
 msgstr ""
 
-#: metadata/lv_manip.c:1026
+#: metadata/lv_manip.c:1349
 msgid "Couldn't allocate new mirror segment."
 msgstr ""
 
-#: metadata/lv_manip.c:1087
+#: metadata/lv_manip.c:1384
+msgid "Mirrored LV must only have one segment."
+msgstr ""
+
+#: metadata/lv_manip.c:1394
+#, c-format
+msgid "Failed to allocate widened LV segment for %s."
+msgstr ""
+
+#: metadata/lv_manip.c:1446
 #, c-format
 msgid "Aborting. Failed to extend %s."
 msgstr ""
 
-#: metadata/lv_manip.c:1140
+#: metadata/lv_manip.c:1499
 #, c-format
 msgid "Maximum number of logical volumes (%u) reached in volume group %s"
 msgstr ""
 
-#: metadata/lv_manip.c:1147
+#: metadata/lv_manip.c:1506
 msgid "Failed to generate unique name for the new logical volume"
 msgstr ""
 
-#: metadata/lv_manip.c:1153
+#: metadata/lv_manip.c:1512
 #, c-format
 msgid "Creating logical volume %s"
 msgstr ""
 
-#: metadata/lv_manip.c:1157
+#: metadata/lv_manip.c:1516
 msgid "lv_list allocation failed"
 msgstr ""
 
-#: metadata/lv_manip.c:1167
+#: metadata/lv_manip.c:1526
 msgid "lv name strdup failed"
 msgstr ""
 
+#: metadata/lv_manip.c:1574 metadata/metadata.c:986
+msgid "pv_list allocation failed"
+msgstr ""
+
+#: metadata/lv_manip.c:1596
+msgid "parallel_areas allocation failed"
+msgstr ""
+
+#: metadata/lv_manip.c:1604
+msgid "allocation failed"
+msgstr ""
+
 #: metadata/merge.c:72
 #, c-format
 msgid "LV %s invalid: segment %u should begin at LE %u (found %u)."
@@ -4471,475 +4911,665 @@
 
 #: metadata/merge.c:90
 #, c-format
+msgid "LV %s: segment %u has log LV but is not mirrored"
+msgstr ""
+
+#: metadata/merge.c:97
+#, c-format
+msgid "LV %s: segment %u log LV %s is not a mirror log"
+msgstr ""
+
+#: metadata/merge.c:105
+#, c-format
+msgid "LV %s: segment %u log LV does not point back to mirror segment"
+msgstr ""
+
+#: metadata/merge.c:115
+#, c-format
+msgid "LV %s: segment %u mirror image is not mirrored"
+msgstr ""
+
+#: metadata/merge.c:124
+#, c-format
 msgid "LV %s: segment %u has unassigned area %u."
 msgstr ""
 
-#: metadata/merge.c:98
+#: metadata/merge.c:132
 #, c-format
 msgid "LV %s: segment %u has inconsistent PV area %u"
 msgstr ""
 
-#: metadata/merge.c:107
+#: metadata/merge.c:141
 #, c-format
 msgid "LV %s: segment %u has inconsistent LV area %u"
 msgstr ""
 
-#: metadata/merge.c:128
+#: metadata/merge.c:152
+#, c-format
+msgid "LV %s: segment %u mirror image %u missing mirror ptr"
+msgstr ""
+
+#: metadata/merge.c:174
 #, c-format
 msgid "LV %s: inconsistent LE count %u != %u"
 msgstr ""
 
-#: metadata/merge.c:149
+#: metadata/merge.c:195
 #, c-format
 msgid "Unable to split the %s segment at LE %u in LV %s"
 msgstr ""
 
-#: metadata/merge.c:162
+#: metadata/merge.c:208
 msgid "Couldn't allocate cloned LV segment."
 msgstr ""
 
-#: metadata/merge.c:167
+#: metadata/merge.c:213
 msgid "LV segment tags duplication failed"
 msgstr ""
 
-#: metadata/merge.c:194
+#: metadata/merge.c:240
 #, c-format
 msgid "Split %s:%u[%u] at %u: %s LE %u"
 msgstr ""
 
-#: metadata/merge.c:210
+#: metadata/merge.c:256
 #, c-format
 msgid "Split %s:%u[%u] at %u: %s PE %u"
 msgstr ""
 
-#: metadata/merge.c:217 metadata/metadata.c:469
+#: metadata/merge.c:263 metadata/metadata.c:495
 #, c-format
 msgid "Unassigned area %u found in segment"
 msgstr ""
 
-#: metadata/merge.c:236
+#: metadata/merge.c:282
 #, c-format
 msgid "Segment with extent %u in LV %s not found"
 msgstr ""
 
-#: metadata/metadata.c:35
+#: metadata/metadata.c:43
 #, c-format
 msgid "Adding physical volume '%s' to volume group '%s'"
 msgstr ""
 
-#: metadata/metadata.c:39
+#: metadata/metadata.c:47 metadata/metadata.c:1008
 #, c-format
 msgid "pv_list allocation for '%s' failed"
 msgstr ""
 
-#: metadata/metadata.c:45
+#: metadata/metadata.c:53
 #, c-format
 msgid "%s not identified as an existing physical volume"
 msgstr ""
 
-#: metadata/metadata.c:51
+#: metadata/metadata.c:59
 #, c-format
 msgid "Physical volume '%s' is already in volume group '%s'"
 msgstr ""
 
-#: metadata/metadata.c:57
+#: metadata/metadata.c:65
 #, c-format
 msgid "Physical volume %s is of different format type (%s)"
 msgstr ""
 
-#: metadata/metadata.c:63 metadata/metadata.c:175
+#: metadata/metadata.c:72
+#, c-format
+msgid "Physical volume %s might be constructed from same volume group %s"
+msgstr ""
+
+#: metadata/metadata.c:78 metadata/metadata.c:199
 #, c-format
 msgid "vg->name allocation failed for '%s'"
 msgstr ""
 
-#: metadata/metadata.c:86
+#: metadata/metadata.c:100
 #, c-format
 msgid "Format-specific setup of physical volume '%s' failed."
 msgstr ""
 
-#: metadata/metadata.c:92
+#: metadata/metadata.c:106
 #, c-format
 msgid "Physical volume '%s' listed more than once."
 msgstr ""
 
-#: metadata/metadata.c:98
+#: metadata/metadata.c:112
 #, c-format
 msgid "No space for '%s' - volume group '%s' holds max %d physical volume(s)."
 msgstr ""
 
-#: metadata/metadata.c:125
+#: metadata/metadata.c:127
+#, c-format
+msgid "Unable to add %s to %s: new extent count (%lu) exceeds limit (%u)."
+msgstr ""
+
+#: metadata/metadata.c:148
 msgid "PV tags duplication failed"
 msgstr ""
 
-#: metadata/metadata.c:146
+#: metadata/metadata.c:170
 #, c-format
 msgid "get_pv_from_vg_by_id: vg_read failed to read VG %s"
 msgstr ""
 
-#: metadata/metadata.c:152
+#: metadata/metadata.c:176
 #, c-format
 msgid "Warning: Volume group %s is not consistent"
 msgstr ""
 
-#: metadata/metadata.c:181
+#: metadata/metadata.c:205
 #, c-format
 msgid "pv->vg_name allocation failed for '%s'"
 msgstr ""
 
-#: metadata/metadata.c:198
+#: metadata/metadata.c:222
 #, c-format
 msgid "Unable to add physical volume '%s' to volume group '%s'."
 msgstr ""
 
-#: metadata/metadata.c:236
+#: metadata/metadata.c:260
 #, c-format
 msgid "A volume group called '%s' already exists."
 msgstr ""
 
-#: metadata/metadata.c:242
+#: metadata/metadata.c:266
 #, c-format
 msgid "Couldn't create uuid for volume group '%s'."
 msgstr ""
 
-#: metadata/metadata.c:283 metadata/metadata.c:934 metadata/metadata.c:977
+#: metadata/metadata.c:309 metadata/metadata.c:1085 metadata/metadata.c:1151
 msgid "Failed to create format instance"
 msgstr ""
 
-#: metadata/metadata.c:289
+#: metadata/metadata.c:315
 #, c-format
 msgid "Format specific setup of volume group '%s' failed."
 msgstr ""
 
-#: metadata/metadata.c:312
+#: metadata/metadata.c:338
 #, c-format
-msgid "New size %llu for %s%s not an exact number of new extents."
+msgid "New size %lu for %s%s not an exact number of new extents."
 msgstr ""
 
-#: metadata/metadata.c:320
+#: metadata/metadata.c:346
 #, c-format
-msgid "New extent count %llu for %s%s exceeds 32 bits."
+msgid "New extent count %lu for %s%s exceeds 32 bits."
 msgstr ""
 
-#: metadata/metadata.c:502
+#: metadata/metadata.c:556
 #, c-format
 msgid "Failed to create random uuid for %s."
 msgstr ""
 
-#: metadata/metadata.c:517 vgreduce.c:196 vgremove.c:62
-#, c-format
-msgid "%s: Couldn't get size."
-msgstr ""
-
-#: metadata/metadata.c:523
+#: metadata/metadata.c:575 pvresize.c:128
 #, c-format
 msgid "WARNING: %s: Overriding real size. You could lose data."
 msgstr ""
 
-#: metadata/metadata.c:525
+#: metadata/metadata.c:577
 #, c-format
-msgid "%s: Pretending size is %llu sectors."
+msgid "%s: Pretending size is %lu sectors."
 msgstr ""
 
-#: metadata/metadata.c:531
+#: metadata/metadata.c:583 pvresize.c:136
 #, c-format
 msgid "%s: Size must exceed minimum of %ld sectors."
 msgstr ""
 
-#: metadata/metadata.c:549
+#: metadata/metadata.c:601
 #, c-format
 msgid "%s: Format-specific setup of physical volume failed."
 msgstr ""
 
-#: metadata/metadata.c:647
+#: metadata/metadata.c:699
 #, c-format
 msgid "Physical volume %s not found"
 msgstr ""
 
-#: metadata/metadata.c:652
+#: metadata/metadata.c:704
 #, c-format
 msgid "Physical volume %s not in a volume group"
 msgstr ""
 
-#: metadata/metadata.c:705 metadata/metadata.c:1066
+#: metadata/metadata.c:780
+#, c-format
+msgid "Internal error: Duplicate PV id %s detected for %s in %s."
+msgstr ""
+
+#: metadata/metadata.c:789
+#, c-format
+msgid "Internal error: VG name for PV %s is corrupted"
+msgstr ""
+
+#: metadata/metadata.c:796 metadata/metadata.c:1278
 #, c-format
 msgid "Internal error: PV segments corrupted in %s."
 msgstr ""
 
-#: metadata/metadata.c:712 metadata/metadata.c:1073
+#: metadata/metadata.c:806
+#, c-format
+msgid "Internal error: Duplicate LV name %s detected in %s."
+msgstr ""
+
+#: metadata/metadata.c:816
+#, c-format
+msgid "Internal error: Duplicate LV id %s detected for %s and %s in %s."
+msgstr ""
+
+#: metadata/metadata.c:827 metadata/metadata.c:1285
 #, c-format
 msgid "Internal error: LV segments corrupted in %s."
 msgstr ""
 
-#: metadata/metadata.c:736
+#: metadata/metadata.c:851
 #, c-format
 msgid "Cannot change metadata for partial volume group %s"
 msgstr ""
 
-#: metadata/metadata.c:742
+#: metadata/metadata.c:857
 msgid "Aborting vg_write: No metadata areas to write to!"
 msgstr ""
 
-#: metadata/metadata.c:751
+#: metadata/metadata.c:866
 msgid "Format does not support writing volumegroup metadata areas"
 msgstr ""
 
-#: metadata/metadata.c:854
+#: metadata/metadata.c:969
 msgid "vg allocation failed"
 msgstr ""
 
-#: metadata/metadata.c:862
+#: metadata/metadata.c:977
 msgid "vg name allocation failed"
 msgstr ""
 
-#: metadata/metadata.c:871
-msgid "pv_list allocation failed"
-msgstr ""
-
-#: metadata/metadata.c:901
+#: metadata/metadata.c:1049
 msgid "Internal error: vg_read requires vgname with pre-commit."
 msgstr ""
 
-#: metadata/metadata.c:927 metadata/metadata.c:970
+#: metadata/metadata.c:1113 metadata/metadata.c:1122
 #, c-format
-msgid "Internal error: %s doesn't support pre-commit"
+msgid "Cached VG %s had incorrect PV list"
 msgstr ""
 
-#: metadata/metadata.c:1014
+#: metadata/metadata.c:1201
 #, c-format
 msgid "Inconsistent pre-commit metadata copies for volume group %s"
 msgstr ""
 
-#: metadata/metadata.c:1025
+#: metadata/metadata.c:1212
 #, c-format
 msgid "Inconsistent metadata copies found for partial volume group %s"
 msgstr ""
 
-#: metadata/metadata.c:1031
+#: metadata/metadata.c:1220
+#, c-format
+msgid "Inconsistent metadata UUIDs found for volume group %s"
+msgstr ""
+
+#: metadata/metadata.c:1226
 #, c-format
-msgid "Inconsistent metadata copies found - updating to use version %u"
+msgid "Inconsistent metadata found for VG %s - updating to use version %u"
 msgstr ""
 
-#: metadata/metadata.c:1034
+#: metadata/metadata.c:1230
 msgid "Automatic metadata correction failed"
 msgstr ""
 
-#: metadata/metadata.c:1038
+#: metadata/metadata.c:1235
 msgid "Automatic metadata correction commit failed"
 msgstr ""
 
-#: metadata/metadata.c:1045
+#: metadata/metadata.c:1247
+#, c-format
+msgid "Removing PV %s (%s) that no longer belongs to VG %s"
+msgstr ""
+
+#: metadata/metadata.c:1257
 #, c-format
 msgid "WARNING: Interrupted pvmove detected in volume group %s"
 msgstr ""
 
-#: metadata/metadata.c:1047
+#: metadata/metadata.c:1259
 msgid "Please restore the metadata by running vgcfgrestore."
 msgstr ""
 
-#: metadata/metadata.c:1108 metadata/metadata.c:1138
+#: metadata/metadata.c:1316 metadata/metadata.c:1348
 #, c-format
 msgid "Volume group %s metadata is inconsistent"
 msgstr ""
 
-#: metadata/metadata.c:1126
+#: metadata/metadata.c:1335
 msgid "vg_read_by_vgid: get_vgs failed"
 msgstr ""
 
-#: metadata/metadata.c:1158
+#: metadata/metadata.c:1369
 #, c-format
 msgid "Finding volume group for uuid %s"
 msgstr ""
 
-#: metadata/metadata.c:1160
+#: metadata/metadata.c:1371
 #, c-format
 msgid "Volume group for uuid not found: %s"
 msgstr ""
 
-#: metadata/metadata.c:1164
+#: metadata/metadata.c:1375
 #, c-format
 msgid "Found volume group \"%s\""
 msgstr ""
 
-#: metadata/metadata.c:1170
+#: metadata/metadata.c:1381
 #, c-format
 msgid "Can't find logical volume id %s"
 msgstr ""
 
-#: metadata/metadata.c:1194
+#: metadata/metadata.c:1405
 #, c-format
 msgid "No physical volume label read from %s"
 msgstr ""
 
-#: metadata/metadata.c:1204
+#: metadata/metadata.c:1415
 #, c-format
 msgid "pv allocation for '%s' failed"
 msgstr ""
 
-#: metadata/metadata.c:1213
+#: metadata/metadata.c:1424
 #, c-format
 msgid "Failed to read existing physical volume '%s'"
 msgstr ""
 
-#: metadata/metadata.c:1250
+#: metadata/metadata.c:1466
 msgid "PV list allocation failed"
 msgstr ""
 
-#: metadata/metadata.c:1258
+#: metadata/metadata.c:1474
 msgid "get_pvs: get_vgs failed"
 msgstr ""
 
-#: metadata/metadata.c:1278
+#: metadata/metadata.c:1498
 #, c-format
 msgid "Warning: Volume Group %s is not consistent"
 msgstr ""
 
-#: metadata/metadata.c:1296
+#: metadata/metadata.c:1516
 msgid "Format does not support writing physical volumes"
 msgstr ""
 
-#: metadata/metadata.c:1301
+#: metadata/metadata.c:1521
 #, c-format
 msgid "Assertion failed: can't _pv_write non-orphan PV (in VG %s)"
 msgstr ""
 
-#: metadata/mirror.c:111
-msgid "img_lvs allocation failed. Remove new LV and retry."
+#: metadata/metadata.c:1547 vgreduce.c:410
+#, c-format
+msgid ""
+"Failed to clear metadata from physical volume \"%s\" after removal from \"%s"
+"\""
 msgstr ""
 
-#: metadata/mirror.c:118 metadata/mirror.c:124
-msgid "img_name allocation failed. Remove new LV and retry."
+#: metadata/metadata.c:1570 pvcreate.c:81
+#, c-format
+msgid "Device %s not found (or ignored by filtering)."
 msgstr ""
 
-#: metadata/mirror.c:132
-msgid "Aborting. Failed to create submirror LV. Remove new LV and retry."
+#: metadata/metadata.c:1579
+#, c-format
+msgid "Could not find LVM label on %s"
+msgstr ""
+
+#: metadata/metadata.c:1584
+#, c-format
+msgid "Found label on %s, sector %lu, type=%s"
+msgstr ""
+
+#: metadata/mirror.c:52 mirror/mirrored.c:322
+#, c-format
+msgid "Using reduced mirror region size of %u sectors"
+msgstr ""
+
+#: metadata/mirror.c:94
+msgid "Aborting. Unable to tag."
+msgstr ""
+
+#: metadata/mirror.c:100
+msgid "Intermediate VG commit for orphan volume failed."
+msgstr ""
+
+#: metadata/mirror.c:138
+#, c-format
+msgid "Reducing mirror set from %u to %u image(s)%s."
+msgstr ""
+
+#: metadata/mirror.c:183
+msgid "No mirror images found using specified PVs."
+msgstr ""
+
+#: metadata/mirror.c:222
+msgid "intermediate VG write failed."
+msgstr ""
+
+#: metadata/mirror.c:277
+msgid "Bad activation/mirror_log_fault_policy"
+msgstr ""
+
+#: metadata/mirror.c:279
+msgid "Bad activation/mirror_device_fault_policy"
+msgstr ""
+
+#: metadata/mirror.c:317
+#, c-format
+msgid "WARNING: Failed to replace mirror device in %s/%s"
+msgstr ""
+
+#: metadata/mirror.c:321
+#, c-format
+msgid ""
+"WARNING: Use 'lvconvert -m %d %s/%s --corelog' to replace failed devices"
+msgstr ""
+
+#: metadata/mirror.c:324 metadata/mirror.c:341
+#, c-format
+msgid "WARNING: Use 'lvconvert -m %d %s/%s' to replace failed devices"
+msgstr ""
+
+#: metadata/mirror.c:338
+#, c-format
+msgid "WARNING: Failed to replace mirror log device in %s/%s"
+msgstr ""
+
+#: metadata/mirror.c:362
+#, c-format
+msgid "WARNING: Unable to determine mirror sync status of %s/%s."
+msgstr ""
+
+#: metadata/mirror.c:380
+#, c-format
+msgid "WARNING: Bad device removed from mirror volume, %s/%s"
+msgstr ""
+
+#: metadata/mirror.c:393
+#, c-format
+msgid "WARNING: Unable to find substitute device for mirror volume, %s/%s"
+msgstr ""
+
+#: metadata/mirror.c:397
+#, c-format
+msgid ""
+"WARNING: Mirror volume, %s/%s restored - substitute for failed device found."
 msgstr ""
 
-#: metadata/mirror.c:142
+#: metadata/mirror.c:402
 #, c-format
 msgid ""
-"Aborting. Failed to add submirror segment to %s. Remove new LV and retry."
+"WARNING: Mirror volume, %s/%s converted to linear due to device failure."
 msgstr ""
 
-#: metadata/mirror.c:151
+#: metadata/mirror.c:405
+#, c-format
+msgid "WARNING: Mirror volume, %s/%s disk log removed due to device failure."
+msgstr ""
+
+#: metadata/mirror.c:428 metadata/mirror.c:434
+msgid "img_name allocation failed. Remove new LV and retry."
+msgstr ""
+
+#: metadata/mirror.c:443
+msgid "Aborting. Failed to create mirror image LV. Remove new LV and retry."
+msgstr ""
+
+#: metadata/mirror.c:455
+#, c-format
+msgid ""
+"Aborting. Failed to add mirror image segment to %s. Remove new LV and retry."
+msgstr ""
+
+#: metadata/mirror.c:477 metadata/mirror.c:518
+msgid "img_lvs allocation failed. Remove new LV and retry."
+msgstr ""
+
+#: metadata/mirror.c:499
 msgid "Aborting. Failed to add mirror segment. Remove new LV and retry."
 msgstr ""
 
-#: metadata/mirror.c:258
+#: metadata/mirror.c:632
 #, c-format
 msgid "Matched PE range %u-%u against %s %u len %u"
 msgstr ""
 
-#: metadata/mirror.c:267 metadata/mirror.c:498
+#: metadata/mirror.c:641 metadata/mirror.c:872 vgreduce.c:139
 msgid "lv_list alloc failed"
 msgstr ""
 
-#: metadata/mirror.c:277
+#: metadata/mirror.c:651
 #, c-format
 msgid "Moving %s:%u-%u of %s/%s"
 msgstr ""
 
-#: metadata/mirror.c:290
+#: metadata/mirror.c:664
 msgid "Unable to allocate temporary LV for pvmove."
 msgstr ""
 
-#: metadata/mirror.c:305
+#: metadata/mirror.c:679
 #, c-format
 msgid "Moving %u extents of logical volume %s/%s"
 msgstr ""
 
-#: metadata/mirror.c:337
+#: metadata/mirror.c:711
 msgid "No segment found with LE"
 msgstr ""
 
-#: metadata/mirror.c:348
+#: metadata/mirror.c:722
 msgid "Incompatible segments"
 msgstr ""
 
-#: metadata/mirror.c:373
+#: metadata/mirror.c:747
 msgid "Missing error segtype"
 msgstr ""
 
-#: metadata/mirror.c:479
+#: metadata/mirror.c:853
 msgid "lvs list alloc failed"
 msgstr ""
 
-#: metadata/pv_manip.c:31
+#: metadata/pv_manip.c:30
 msgid "pv_segment allocation failed"
 msgstr ""
 
-#: metadata/pv_manip.c:122
+#: metadata/pv_manip.c:121
 #, c-format
 msgid "Segment with extent %u in PV %s not found"
 msgstr ""
 
-#: metadata/pv_manip.c:162
+#: metadata/pv_manip.c:161
 #, c-format
 msgid "Missing PV segment on %s at %u."
 msgstr ""
 
-#: metadata/pv_manip.c:179
+#: metadata/pv_manip.c:178
 #, c-format
 msgid "release_pv_segment with unallocated segment: %s PE %u"
 msgstr ""
 
-#: metadata/pv_manip.c:239
+#: metadata/pv_manip.c:238
 #, c-format
 msgid "%s %u: %6u %6u: %s(%u:%u)"
 msgstr ""
 
-#: metadata/pv_manip.c:245
+#: metadata/pv_manip.c:244
 #, c-format
 msgid "Gap in pvsegs: %u, %u"
 msgstr ""
 
-#: metadata/pv_manip.c:251
+#: metadata/pv_manip.c:250
 msgid "Wrong lvseg area type"
 msgstr ""
 
-#: metadata/pv_manip.c:255
+#: metadata/pv_manip.c:254
 msgid "Inconsistent pvseg pointers"
 msgstr ""
 
-#: metadata/pv_manip.c:259
+#: metadata/pv_manip.c:258
 #, c-format
 msgid "Inconsistent length: %u %u"
 msgstr ""
 
-#: metadata/pv_manip.c:270
+#: metadata/pv_manip.c:269
 #, c-format
 msgid "PV segment pe_count mismatch: %u != %u"
 msgstr ""
 
-#: metadata/pv_manip.c:276
+#: metadata/pv_manip.c:275
 #, c-format
 msgid "PV segment pe_alloc_count mismatch: %u != %u"
 msgstr ""
 
-#: metadata/pv_manip.c:286
+#: metadata/pv_manip.c:285
 #, c-format
 msgid "PV segment VG pv_count mismatch: %u != %u"
 msgstr ""
 
-#: metadata/pv_manip.c:292
+#: metadata/pv_manip.c:291
 #, c-format
 msgid "PV segment VG free_count mismatch: %u != %u"
 msgstr ""
 
-#: metadata/pv_manip.c:298
+#: metadata/pv_manip.c:297
 #, c-format
 msgid "PV segment VG extent_count mismatch: %u != %u"
 msgstr ""
 
-#: metadata/pv_map.c:46
+#: metadata/pv_manip.c:311
+#, c-format
+msgid "%s: cannot resize to %u extents as %u are allocated."
+msgstr ""
+
+#: metadata/pv_manip.c:324
+#, c-format
+msgid "%s: cannot resize to %u extents as later ones are allocated."
+msgstr ""
+
+#: metadata/pv_manip.c:356
+#, c-format
+msgid "%s: cannot resize to %u extents as there is only room for %lu."
+msgstr ""
+
+#: metadata/pv_manip.c:385
+#, c-format
+msgid "No change to size of physical volume %s."
+msgstr ""
+
+#: metadata/pv_manip.c:390
+#, c-format
+msgid "Resizing physical volume %s from %u to %u extents."
+msgstr ""
+
+#: metadata/pv_map.c:48
 #, c-format
 msgid "Allowing allocation on %s start PE %u length %u"
 msgstr ""
 
-#: metadata/pv_map.c:165
+#: metadata/pv_map.c:176
 msgid "create_pv_maps alloc failed"
 msgstr ""
 
-#: metadata/pv_map.c:172
+#: metadata/pv_map.c:183
 #, c-format
 msgid "Couldn't create physical volume maps in %s"
 msgstr ""
@@ -4949,175 +5579,241 @@
 msgid "Unrecognised segment type %s"
 msgstr ""
 
-#: metadata/snapshot_manip.c:49
+#: metadata/snapshot_manip.c:63
 #, c-format
 msgid "'%s' is already in use as a snapshot."
 msgstr ""
 
-#: metadata/snapshot_manip.c:90
+#: metadata/snapshot_manip.c:104
 #, c-format
 msgid "Failed to remove internal snapshot LV %s"
 msgstr ""
 
-#: mirror/mirrored.c:50
+#: mirror/mirrored.c:57
 #, c-format
 msgid "  Mirrors\t\t%u"
 msgstr ""
 
-#: mirror/mirrored.c:51
+#: mirror/mirrored.c:58
 #, c-format
 msgid "  Mirror size\t\t%u"
 msgstr ""
 
-#: mirror/mirrored.c:53
+#: mirror/mirrored.c:60
 #, c-format
 msgid "  Mirror log volume\t%s"
 msgstr ""
 
-#: mirror/mirrored.c:59
+#: mirror/mirrored.c:65
 #, c-format
 msgid "  Mirror region size\t%s"
 msgstr ""
 
-#: mirror/mirrored.c:62
+#: mirror/mirrored.c:68
 msgid "  Mirror original:"
 msgstr ""
 
-#: mirror/mirrored.c:64
-msgid "  Mirror destination:"
+#: mirror/mirrored.c:70
+msgid "  Mirror destinations:"
 msgstr ""
 
-#: mirror/mirrored.c:72
+#: mirror/mirrored.c:79
 #, c-format
 msgid "Couldn't read 'mirror_count' for segment '%s'."
 msgstr ""
 
-#: mirror/mirrored.c:91
+#: mirror/mirrored.c:98
 #, c-format
 msgid "Couldn't read 'extents_moved' for segment '%s'."
 msgstr ""
 
-#: mirror/mirrored.c:100
+#: mirror/mirrored.c:107
 #, c-format
 msgid "Couldn't read 'region_size' for segment '%s'."
 msgstr ""
 
-#: mirror/mirrored.c:108
+#: mirror/mirrored.c:115
 msgid "Mirror log type must be a string."
 msgstr ""
 
-#: mirror/mirrored.c:113
+#: mirror/mirrored.c:120
 #, c-format
 msgid "Unrecognised mirror log in segment %s."
 msgstr ""
 
-#: mirror/mirrored.c:121
+#: mirror/mirrored.c:128
 #, c-format
 msgid "Missing region size for mirror log for segment '%s'."
 msgstr ""
 
-#: mirror/mirrored.c:127
+#: mirror/mirrored.c:134
 #, c-format
 msgid "Couldn't find mirrors array for segment '%s'."
 msgstr ""
 
-#: mirror/mirrored.c:156
+#: mirror/mirrored.c:163
 msgid "struct mirr_state allocation failed"
 msgstr ""
 
-#: mirror/mirrored.c:206
+#: mirror/mirrored.c:193
+#, c-format
+msgid "Mirror status: %s"
+msgstr ""
+
+#: mirror/mirrored.c:196
+#, c-format
+msgid "Failure parsing mirror status mirror count: %s"
+msgstr ""
+
+#: mirror/mirrored.c:204
+#, c-format
+msgid "Failure parsing mirror status devices: %s"
+msgstr ""
+
+#: mirror/mirrored.c:213
+#, c-format
+msgid "Failure parsing mirror status fraction: %s"
+msgstr ""
+
+#: mirror/mirrored.c:245
+#, c-format
+msgid "Failed to build uuid for log LV %s."
+msgstr ""
+
+#: mirror/mirrored.c:252
+#, c-format
+msgid "Failed to build uuid for mirror LV %s."
+msgstr ""
+
+#: mirror/mirrored.c:310
 msgid "Missing region size for mirror segment."
 msgstr ""
 
-#: mirror/mirrored.c:247
+#: mirror/mirrored.c:505
+msgid "cluster log string list allocation failed"
+msgstr ""
+
+#: mirror/mirrored.c:510
+msgid "mirror string list allocation failed"
+msgstr ""
+
+#: misc/lvm-exec.c:31
 #, c-format
-msgid "Mirror status: %s"
+msgid "Executing: %s %s %s %s"
+msgstr ""
+
+#: misc/lvm-exec.c:34 polldaemon.c:39
+#, c-format
+msgid "fork failed: %s"
+msgstr ""
+
+#: misc/lvm-exec.c:48
+#, c-format
+msgid "wait4 child process %u failed: %s"
+msgstr ""
+
+#: misc/lvm-exec.c:54
+#, c-format
+msgid "Child %u exited abnormally"
 msgstr ""
 
-#: mirror/mirrored.c:250
+#: misc/lvm-exec.c:59
 #, c-format
-msgid "Failure parsing mirror status: %s"
+msgid "%s failed: %u"
 msgstr ""
 
 #: misc/lvm-file.c:55
 msgid "Not enough space to build temporary file string."
 msgstr ""
 
-#: misc/lvm-file.c:101
+#: misc/lvm-file.c:102
 #, c-format
 msgid "%s: rename to %s failed"
 msgstr ""
 
-#: misc/lvm-file.c:147
+#: misc/lvm-file.c:148
 #, c-format
 msgid "Creating directory \"%s\""
 msgstr ""
 
-#: misc/lvm-file.c:188
+#: misc/lvm-file.c:189
 #, c-format
 msgid "Directory \"%s\" not found"
 msgstr ""
 
-#: misc/lvm-file.c:219
+#: misc/lvm-file.c:220
 msgid "sync_dir failed in strdup"
 msgstr ""
 
-#: misc/sharedlib.c:41
+#: misc/lvm-file.c:269
+msgid "fcntl_lock_file failed in strdup."
+msgstr ""
+
+#: misc/lvm-file.c:283
 #, c-format
-msgid "Opening shared %s library %s"
+msgid "Locking %s (%s, %hd)"
 msgstr ""
 
-#: misc/sharedlib.c:44
+#: misc/lvm-file.c:313
 #, c-format
-msgid "Unable to open external %s library %s"
+msgid "Unlocking fd %d"
 msgstr ""
 
-#: mm/dbg_malloc.c:239
-msgid "Huge memory allocation (size %zu) rejected - metadata corruption?"
+#: misc/lvm-file.c:316
+#, c-format
+msgid "fcntl unlock failed on fd %d: %s"
 msgstr ""
 
-#: mm/memlock.c:100
-msgid "Locking memory"
+#: misc/lvm-file.c:320
+#, c-format
+msgid "lock file close failed on fd %d: %s"
 msgstr ""
 
-#: mm/memlock.c:109 mm/memlock.c:123
+#: misc/lvm-string.c:107
 #, c-format
-msgid "setpriority %u failed: %s"
+msgid "build_dm_name: Allocation failed for %zu for %s %s %s."
 msgstr ""
 
-#: mm/memlock.c:119
-msgid "Unlocking memory"
+#: misc/sharedlib.c:48
+#, c-format
+msgid "Not loading shared %s library %s in static mode."
 msgstr ""
 
-#: mm/memlock.c:131
+#: misc/sharedlib.c:55
 #, c-format
-msgid "memlock_count inc to %d"
+msgid "Opening shared %s library %s"
 msgstr ""
 
-#: mm/memlock.c:138
+#: misc/sharedlib.c:59 misc/sharedlib.c:62
 #, c-format
-msgid "memlock_count dec to %d"
+msgid "Unable to open external %s library %s: %s"
 msgstr ""
 
-#: mm/pool-fast.c:45
-msgid "Couldn't create memory pool %s (size %zu)"
+#: mm/memlock.c:99
+msgid "Locking memory"
 msgstr ""
 
-#: mm/pool-fast.c:134
-msgid "Internal error: pool_free asked to free pointer not in pool"
+#: mm/memlock.c:108 mm/memlock.c:122
+#, c-format
+msgid "setpriority %u failed: %s"
 msgstr ""
 
-#: mm/pool-fast.c:223
-msgid "Out of memory.  Requested %zu bytes."
+#: mm/memlock.c:118
+msgid "Unlocking memory"
 msgstr ""
 
-#: polldaemon.c:34
-msgid "Forking background process"
+#: mm/memlock.c:130
+#, c-format
+msgid "memlock_count inc to %d"
 msgstr ""
 
-#: polldaemon.c:39 toollib.c:984
+#: mm/memlock.c:137
 #, c-format
-msgid "fork failed: %s"
+msgid "memlock_count dec to %d"
+msgstr ""
+
+#: polldaemon.c:34
+msgid "Forking background process"
 msgstr ""
 
 #: polldaemon.c:49
@@ -5125,48 +5821,48 @@
 msgid "Background process failed to setsid: %s"
 msgstr ""
 
-#: polldaemon.c:82
+#: polldaemon.c:80
 msgid "Failed to generate list of copied LVs: can't abort."
 msgstr ""
 
-#: polldaemon.c:92
+#: polldaemon.c:90
 msgid "ABORTING: Mirror percentage check failed."
 msgstr ""
 
-#: polldaemon.c:98 polldaemon.c:100
+#: polldaemon.c:96 polldaemon.c:98
 #, c-format
 msgid "%s: Moved: %.1f%%"
 msgstr ""
 
-#: polldaemon.c:112
+#: polldaemon.c:107
 msgid "ABORTING: Failed to generate list of copied LVs"
 msgstr ""
 
-#: polldaemon.c:124
+#: polldaemon.c:119
 msgid "ABORTING: Segment progression failed."
 msgstr ""
 
-#: polldaemon.c:154
+#: polldaemon.c:149
 #, c-format
 msgid "ABORTING: Can't reread VG for %s"
 msgstr ""
 
-#: polldaemon.c:161
+#: polldaemon.c:156
 #, c-format
 msgid "ABORTING: Can't find mirror LV in %s for %s"
 msgstr ""
 
-#: polldaemon.c:189
+#: polldaemon.c:184
 #, c-format
 msgid "Couldn't read volume group %s"
 msgstr ""
 
-#: polldaemon.c:194
+#: polldaemon.c:189
 #, c-format
 msgid "Volume Group %s inconsistent - skipping"
 msgstr ""
 
-#: polldaemon.c:246
+#: polldaemon.c:241
 #, c-format
 msgid "Checking progress every %u seconds"
 msgstr ""
@@ -5176,140 +5872,145 @@
 msgid "Finding volume group of physical volume \"%s\""
 msgstr ""
 
-#: pvchange.c:65
+#: pvchange.c:65 pvresize.c:75
 #, c-format
 msgid "Unable to find volume group of \"%s\""
 msgstr ""
 
-#: pvchange.c:85
+#: pvchange.c:90 pvresize.c:101
 #, c-format
 msgid "Unable to find \"%s\" in volume group \"%s\""
 msgstr ""
 
-#: pvchange.c:91
+#: pvchange.c:97
 #, c-format
 msgid "Volume group containing %s does not support tags"
 msgstr ""
 
-#: pvchange.c:97
+#: pvchange.c:103
 #, c-format
 msgid "Volume group containing %s has active logical volumes"
 msgstr ""
 
-#: pvchange.c:106
+#: pvchange.c:112
 #, c-format
 msgid "Can't change tag on Physical Volume %s not in volume group"
 msgstr ""
 
-#: pvchange.c:111
+#: pvchange.c:117 pvresize.c:48
 msgid "Can't get lock for orphans"
 msgstr ""
 
-#: pvchange.c:117
+#: pvchange.c:123 pvresize.c:54
 #, c-format
 msgid "Unable to read PV \"%s\""
 msgstr ""
 
-#: pvchange.c:126
+#: pvchange.c:132
 #, c-format
 msgid "Allocatability not supported by orphan %s format PV %s"
 msgstr ""
 
-#: pvchange.c:134
+#: pvchange.c:140
 #, c-format
 msgid "Physical volume \"%s\" is already allocatable"
 msgstr ""
 
-#: pvchange.c:144
+#: pvchange.c:150
 #, c-format
 msgid "Physical volume \"%s\" is already unallocatable"
 msgstr ""
 
-#: pvchange.c:154
+#: pvchange.c:160
 #, c-format
 msgid "Setting physical volume \"%s\" allocatable"
 msgstr ""
 
-#: pvchange.c:158
+#: pvchange.c:164
 #, c-format
 msgid "Setting physical volume \"%s\" NOT allocatable"
 msgstr ""
 
-#: pvchange.c:166
+#: pvchange.c:172
 #, c-format
 msgid "Failed to add tag %s to physical volume %s"
 msgstr ""
 
-#: pvchange.c:172
+#: pvchange.c:178
 #, c-format
 msgid "Failed to remove tag %s from physical volume%s"
 msgstr ""
 
-#: pvchange.c:180
+#: pvchange.c:186
 #, c-format
 msgid "Failed to generate new random UUID for %s."
 msgstr ""
 
-#: pvchange.c:188
+#: pvchange.c:194
 #, c-format
 msgid "Changing uuid of %s to %s."
 msgstr ""
 
-#: pvchange.c:195
+#: pvchange.c:201
 #, c-format
 msgid "pv_write with new uuid failed for %s."
 msgstr ""
 
-#: pvchange.c:204
+#: pvchange.c:210 pvresize.c:174
 #, c-format
 msgid "Updating physical volume \"%s\""
 msgstr ""
 
-#: pvchange.c:208
+#: pvchange.c:214 pvresize.c:178
 #, c-format
 msgid "Failed to store physical volume \"%s\" in volume group \"%s\""
 msgstr ""
 
-#: pvchange.c:217
+#: pvchange.c:223 pvresize.c:187
 #, c-format
 msgid "Failed to store physical volume \"%s\""
 msgstr ""
 
-#: pvchange.c:224
+#: pvchange.c:230 pvresize.c:194
 #, c-format
 msgid "Physical volume \"%s\" changed"
 msgstr ""
 
-#: pvchange.c:246
+#: pvchange.c:252
 msgid "Please give exactly one option of -x, -uuid, --addtag or --deltag"
 msgstr ""
 
-#: pvchange.c:252
+#: pvchange.c:258
 msgid "Please give a physical volume path"
 msgstr ""
 
-#: pvchange.c:257
+#: pvchange.c:263
 msgid "Option a and PhysicalVolumePath are exclusive"
 msgstr ""
 
-#: pvchange.c:262 toollib.c:537
+#: pvchange.c:268 toollib.c:683
 msgid "Using physical volume(s) on command line"
 msgstr ""
 
-#: pvchange.c:267
+#: pvchange.c:273
 #, c-format
 msgid "Failed to read physical volume %s"
 msgstr ""
 
-#: pvchange.c:275 toollib.c:607
+#: pvchange.c:281 toollib.c:766
 msgid "Scanning for physical volume names"
 msgstr ""
 
-#: pvchange.c:286
+#: pvchange.c:292
 #, c-format
 msgid "%d physical volume%s changed / %d physical volume%s not changed"
 msgstr ""
 
+#: pvck.c:32
+#, c-format
+msgid "Scanning %s"
+msgstr ""
+
 #: pvcreate.c:37 pvremove.c:31
 #, c-format
 msgid "%s: Not LVM partition type: use -f to override"
@@ -5326,840 +6027,817 @@
 msgid "%s: physical volume not initialized"
 msgstr ""
 
-#: pvcreate.c:72 pvcreate.c:162 pvremove.c:76 vgcreate.c:139 vgextend.c:40
-#: vgremove.c:91
+#: pvcreate.c:72 pvcreate.c:168 pvremove.c:81 vgcreate.c:135 vgextend.c:40
+#: vgremove.c:96
 msgid "Can't get lock for orphan PVs"
 msgstr ""
 
-#: pvcreate.c:81
+#: pvcreate.c:86
 #, c-format
-msgid "Device %s not found."
+msgid "Can't open %s exclusively.  Mounted filesystem?"
 msgstr ""
 
-#: pvcreate.c:92
+#: pvcreate.c:98
 #, c-format
 msgid "Wiping software RAID md superblock on %s"
 msgstr ""
 
-#: pvcreate.c:94
+#: pvcreate.c:100
 #, c-format
 msgid "Failed to wipe RAID md superblock on %s"
 msgstr ""
 
-#: pvcreate.c:101
+#: pvcreate.c:107
 #, c-format
 msgid "WARNING: Forcing physical volume creation on %s%s%s%s"
 msgstr ""
 
-#: pvcreate.c:134
+#: pvcreate.c:140
 #, c-format
 msgid "uuid %s already in use on \"%s\""
 msgstr ""
 
-#: pvcreate.c:146
+#: pvcreate.c:152
 #, c-format
 msgid "Unable to read volume group from %s"
 msgstr ""
 
-#: pvcreate.c:152
+#: pvcreate.c:158
 #, c-format
 msgid "Can't find uuid %s in backup file %s"
 msgstr ""
 
-#: pvcreate.c:170
+#: pvcreate.c:176 pvresize.c:212
 msgid "Physical volume size may not be negative"
 msgstr ""
 
-#: pvcreate.c:176 vgconvert.c:66
+#: pvcreate.c:182 vgconvert.c:66
 msgid "Metadata size may not be negative"
 msgstr ""
 
-#: pvcreate.c:193 pvremove.c:84
+#: pvcreate.c:199 pvremove.c:89
 #, c-format
 msgid "%s: Couldn't find device.  Check your filters?"
 msgstr ""
 
-#: pvcreate.c:202 vgconvert.c:127
+#: pvcreate.c:208 vgconvert.c:127
 #, c-format
 msgid "Failed to setup physical volume \"%s\""
 msgstr ""
 
-#: pvcreate.c:206 vgconvert.c:138
+#: pvcreate.c:212 vgconvert.c:138
 #, c-format
-msgid "Set up physical volume for \"%s\" with %llu available sectors"
+msgid "Set up physical volume for \"%s\" with %lu available sectors"
 msgstr ""
 
-#: pvcreate.c:211 vgconvert.c:143
+#: pvcreate.c:217 vgconvert.c:143
 #, c-format
 msgid "Failed to wipe existing label on %s"
 msgstr ""
 
-#: pvcreate.c:216
+#: pvcreate.c:222
 #, c-format
 msgid "Zeroing start of device %s"
 msgstr ""
 
-#: pvcreate.c:218
+#: pvcreate.c:224
 #, c-format
 msgid "%s not opened: device not zeroed"
 msgstr ""
 
-#: pvcreate.c:226 vgconvert.c:150
+#: pvcreate.c:229
+#, c-format
+msgid "%s not wiped: aborting"
+msgstr ""
+
+#: pvcreate.c:236 vgconvert.c:150
 #, c-format
 msgid "Writing physical volume data to disk \"%s\""
 msgstr ""
 
-#: pvcreate.c:230 vgconvert.c:155
+#: pvcreate.c:240 vgconvert.c:155
 #, c-format
 msgid "Failed to write physical volume \"%s\""
 msgstr ""
 
-#: pvcreate.c:234 vgconvert.c:161
+#: pvcreate.c:244 vgconvert.c:161
 #, c-format
 msgid "Physical volume \"%s\" successfully created"
 msgstr ""
 
-#: pvcreate.c:251 pvremove.c:112
+#: pvcreate.c:261 pvremove.c:123
 msgid "Please enter a physical volume path"
 msgstr ""
 
-#: pvcreate.c:256
+#: pvcreate.c:266
 msgid "--uuid is required with --restorefile"
 msgstr ""
 
-#: pvcreate.c:261
+#: pvcreate.c:271
 msgid "Can only set uuid on one volume at once"
 msgstr ""
 
-#: pvcreate.c:266 pvremove.c:117
+#: pvcreate.c:276 pvremove.c:128
 msgid "Option y can only be given with option f"
 msgstr ""
 
-#: pvcreate.c:271 vgconvert.c:205
+#: pvcreate.c:281 vgconvert.c:205
 #, c-format
 msgid "labelsector must be less than %lu"
 msgstr ""
 
-#: pvcreate.c:279 vgconvert.c:213
+#: pvcreate.c:289 vgconvert.c:213
 msgid "Metadata parameters only apply to text format"
 msgstr ""
 
-#: pvcreate.c:285 vgconvert.c:219
+#: pvcreate.c:295 vgconvert.c:219
 msgid "Metadatacopies may only be 0, 1 or 2"
 msgstr ""
 
-#: pvdisplay.c:31
+#: pvdisplay.c:30 reporter.c:65 reporter.c:113 toollib.c:347 toollib.c:477
+#, c-format
+msgid "Can't lock %s: skipping"
+msgstr ""
+
+#: pvdisplay.c:35 reporter.c:70 reporter.c:118
+#, c-format
+msgid "Can't read %s: skipping"
+msgstr ""
+
+#: pvdisplay.c:54
 #, c-format
 msgid "Device \"%s\" has a capacity of %s"
 msgstr ""
 
-#: pvdisplay.c:37
+#: pvdisplay.c:60
 #, c-format
 msgid "Physical volume \"%s\" of volume group \"%s\" is exported"
 msgstr ""
 
-#: pvdisplay.c:41
+#: pvdisplay.c:64
 #, c-format
 msgid "\"%s\" is a new physical volume of \"%s\""
 msgstr ""
 
-#: pvdisplay.c:77
+#: pvdisplay.c:104
 msgid "Option -v not allowed with option -c"
 msgstr ""
 
-#: pvmove.c:36
+#: pvmove.c:34
 msgid "--name takes a logical volume name"
 msgstr ""
 
-#: pvmove.c:41
+#: pvmove.c:39
 msgid "Named LV and old PV must be in the same VG"
 msgstr ""
 
-#: pvmove.c:47
+#: pvmove.c:45
 msgid "Incomplete LV name supplied with --name"
 msgstr ""
 
-#: pvmove.c:123
+#: pvmove.c:127
 msgid "No extents available for allocation"
 msgstr ""
 
-#: pvmove.c:146
+#: pvmove.c:150
 msgid "Creation of temporary pvmove LV failed"
 msgstr ""
 
-#: pvmove.c:153
+#: pvmove.c:157
 msgid "lvs_changed list struct allocation failed"
 msgstr ""
 
-#: pvmove.c:166
+#: pvmove.c:170
 #, c-format
 msgid "Skipping snapshot-related LV %s"
 msgstr ""
 
-#: pvmove.c:170
+#: pvmove.c:174
 #, c-format
 msgid "Skipping mirror LV %s"
 msgstr ""
 
-#: pvmove.c:174
+#: pvmove.c:178
 #, c-format
 msgid "Skipping mirror log LV %s"
 msgstr ""
 
-#: pvmove.c:178
+#: pvmove.c:182
 #, c-format
 msgid "Skipping mirror image LV %s"
 msgstr ""
 
-#: pvmove.c:182
+#: pvmove.c:186
 #, c-format
 msgid "Skipping locked LV %s"
 msgstr ""
 
-#: pvmove.c:195
+#: pvmove.c:199
 #, c-format
 msgid "No data to move for %s"
 msgstr ""
 
-#: pvmove.c:206
+#: pvmove.c:210
 msgid "Updating volume group metadata"
 msgstr ""
 
-#: pvmove.c:208 pvmove.c:232
+#: pvmove.c:212 pvmove.c:236
 msgid "ABORTING: Volume group metadata update failed."
 msgstr ""
 
-#: pvmove.c:244
+#: pvmove.c:249
 msgid "ABORTING: Temporary mirror activation failed.  Run pvmove --abort."
 msgstr ""
 
-#: pvmove.c:252 pvmove.c:434
-#, c-format
-msgid "Unable to reactivate logical volume \"%s\""
-msgstr ""
-
-#: pvmove.c:260
-msgid "Unable to resume logical volumes"
-msgstr ""
-
-#: pvmove.c:308
-#, c-format
-msgid "Detected pvmove in progress for %s"
-msgstr ""
-
-#: pvmove.c:310
-msgid "Ignoring remaining command line arguments"
-msgstr ""
-
-#: pvmove.c:314
-msgid "ABORTING: Failed to generate list of moving LVs"
-msgstr ""
-
-#: pvmove.c:322
-msgid "ABORTING: Temporary mirror activation failed."
-msgstr ""
-
-#: pvmove.c:399
-msgid "ABORTING: Removal of temporary mirror failed"
-msgstr ""
-
-#: pvmove.c:405 pvmove.c:424 pvmove.c:458
-msgid "ABORTING: Failed to write new data locations to disk."
-msgstr ""
-
-#: pvmove.c:412
-msgid "Locking LVs to remove temporary mirror failed"
-msgstr ""
-
-#: pvmove.c:418
-msgid "Suspension of temporary mirror LV failed"
-msgstr ""
-
-#: pvmove.c:444
-#, c-format
-msgid "ABORTING: Unable to deactivate temporary logical volume \"%s\""
-msgstr ""
-
-#: pvmove.c:449
-msgid "Removing temporary pvmove LV"
-msgstr ""
-
-#: pvmove.c:451
-msgid "ABORTING: Removal of temporary pvmove LV failed"
-msgstr ""
-
-#: pvmove.c:456
-msgid "Writing out final volume group after pvmove"
-msgstr ""
-
-#: pvmove.c:476
-#, c-format
-msgid "ABORTING: Can't reread PV %s"
-msgstr ""
-
-#: pvmove.c:512 toollib.c:908
-msgid "Failed to clone PV name"
-msgstr ""
-
-#: pvremove.c:47
-#, c-format
-msgid ""
-"Can't pvremove physical volume \"%s\" of volume group \"%s\" without -ff"
-msgstr ""
-
-#: pvremove.c:55
-#, c-format
-msgid "%s: physical volume label not removed"
-msgstr ""
-
-#: pvremove.c:60
-#, c-format
-msgid "WARNING: Wiping physical volume label from %s%s%s%s"
-msgstr ""
-
-#: pvremove.c:91
-#, c-format
-msgid "Failed to wipe existing label(s) on %s"
-msgstr ""
-
-#: pvremove.c:95
-#, c-format
-msgid "Labels on physical volume \"%s\" successfully wiped"
-msgstr ""
-
-#: pvscan.c:65
-#, c-format
-msgid "PV %-*s    %-*s %s [%s]"
-msgstr ""
-
-#: pvscan.c:75
-#, c-format
-msgid "PV %-*s  is in exported VG %s [%s / %s free]"
-msgstr ""
-
-#: pvscan.c:88
+#: pvmove.c:257 pvmove.c:438
 #, c-format
-msgid "PV %-*s VG %-*s %s [%s / %s free]"
+msgid "Unable to reactivate logical volume \"%s\""
 msgstr ""
 
-#: pvscan.c:117
-msgid "Options -e and -n are incompatible"
+#: pvmove.c:265
+msgid "Unable to resume logical volumes"
 msgstr ""
 
-#: pvscan.c:122
+#: pvmove.c:313
 #, c-format
-msgid "WARNING: only considering physical volumes %s"
+msgid "Detected pvmove in progress for %s"
 msgstr ""
 
-#: pvscan.c:129
-msgid "Walking through all physical volumes"
+#: pvmove.c:315
+msgid "Ignoring remaining command line arguments"
 msgstr ""
 
-#: pvscan.c:182
-msgid "No matching physical volumes found"
+#: pvmove.c:318
+msgid "ABORTING: Failed to generate list of moving LVs"
 msgstr ""
 
-#: pvscan.c:186
-#, c-format
-msgid "Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]"
+#: pvmove.c:326
+msgid "ABORTING: Temporary mirror activation failed."
 msgstr ""
 
-#: regex/matcher.c:137
-msgid "Internal error: Unknown calc node type"
+#: pvmove.c:403
+msgid "ABORTING: Removal of temporary mirror failed"
 msgstr ""
 
-#: regex/matcher.c:267
-#, c-format
-msgid "Matcher built with %d dfa states"
+#: pvmove.c:409 pvmove.c:428 pvmove.c:462
+msgid "ABORTING: Failed to write new data locations to disk."
 msgstr ""
 
-#: regex/matcher.c:312
-msgid "Couldn't parse regex"
+#: pvmove.c:416
+msgid "Locking LVs to remove temporary mirror failed"
 msgstr ""
 
-#: regex/parse_rx.c:89
-msgid "Incomplete rangespecification"
+#: pvmove.c:422
+msgid "Suspension of temporary mirror LV failed"
 msgstr ""
 
-#: regex/parse_rx.c:167
-msgid "Badly quoted character at end of expression"
+#: pvmove.c:448
+#, c-format
+msgid "ABORTING: Unable to deactivate temporary logical volume \"%s\""
 msgstr ""
 
-#: regex/parse_rx.c:241
-msgid "missing ')' in regular expression"
+#: pvmove.c:453
+msgid "Removing temporary pvmove LV"
 msgstr ""
 
-#: regex/parse_rx.c:323
-msgid "Badly formed 'or' expression"
+#: pvmove.c:455
+msgid "ABORTING: Removal of temporary pvmove LV failed"
 msgstr ""
 
-#: regex/parse_rx.c:351
-msgid "Parse error in regex"
+#: pvmove.c:460
+msgid "Writing out final volume group after pvmove"
 msgstr ""
 
-#: report/report.c:125 report/report.c:541 report/report.c:581
-#: report/report.c:609
-msgid "pool_strdup failed"
+#: pvmove.c:480
+#, c-format
+msgid "ABORTING: Can't reread PV %s"
 msgstr ""
 
-#: report/report.c:152 report/report.c:211
-msgid "pool_begin_object failed"
+#: pvmove.c:516 toollib.c:1074
+msgid "Failed to clone PV name"
 msgstr ""
 
-#: report/report.c:172 report/report.c:183 report/report.c:189
-#: report/report.c:195 report/report.c:218 report/report.c:224
-#: report/report.c:1322
-msgid "pool_grow_object failed"
+#: pvremove.c:41 vgsplit.c:107
+#, c-format
+msgid "Physical Volume %s not found"
 msgstr ""
 
-#: report/report.c:178
-msgid "Extent number lvm_snprintf failed"
+#: pvremove.c:52
+#, c-format
+msgid ""
+"Can't pvremove physical volume \"%s\" of volume group \"%s\" without -ff"
 msgstr ""
 
-#: report/report.c:271 report/report.c:276 report/report.c:332
-#: report/report.c:409 report/report.c:436 report/report.c:529
-#: report/report.c:586 report/report.c:614 report/report.c:731
-#: report/report.c:754 report/report.c:759 report/report.c:783
-#: report/report.c:788 report/report.c:826 report/report.c:847
-#: report/report.c:872 report/report.c:887
-msgid "pool_alloc failed"
+#: pvremove.c:60
+#, c-format
+msgid "%s: physical volume label not removed"
 msgstr ""
 
-#: report/report.c:281
+#: pvremove.c:65
 #, c-format
-msgid "int too big: %d"
+msgid "WARNING: Wiping physical volume label from %s%s%s%s"
 msgstr ""
 
-#: report/report.c:534
-msgid "lvname snprintf failed"
+#: pvremove.c:95
+#, c-format
+msgid "Can't open %s exclusively - not removing. Mounted filesystem?"
 msgstr ""
 
-#: report/report.c:764
+#: pvremove.c:102
 #, c-format
-msgid "uint32 too big: %u"
+msgid "Failed to wipe existing label(s) on %s"
 msgstr ""
 
-#: report/report.c:793
+#: pvremove.c:106
 #, c-format
-msgid "int32 too big: %d"
+msgid "Labels on physical volume \"%s\" successfully wiped"
 msgstr ""
 
-#: report/report.c:852
-msgid "snapshot percentage too large"
+#: pvresize.c:60
+#, c-format
+msgid "%s: too many metadata areas for pvresize"
 msgstr ""
 
-#: report/report.c:892
-msgid "copy percentage too large"
+#: pvresize.c:113
+#, c-format
+msgid "Physical volume %s format does not support resizing."
 msgstr ""
 
-#: report/report.c:949 report/report.c:985
-msgid "struct field_properties allocation failed"
+#: pvresize.c:130
+#, c-format
+msgid "%s: Pretending size is %lu not %lu sectors."
 msgstr ""
 
-#: report/report.c:998
+#: pvresize.c:143
 #, c-format
-msgid "Ignoring duplicate sort field: %s"
+msgid "%s: Size must exceed physical extent start of %lu sectors."
 msgstr ""
 
-#: report/report.c:1030
-msgid "Missing sort field name"
+#: pvresize.c:156
+#, c-format
+msgid ""
+"%s: Size must leave space for at least one physical extent of %u sectors."
 msgstr ""
 
-#: report/report.c:1061 report/report.c:1083
+#: pvresize.c:171
 #, c-format
-msgid "Unrecognised field: %.*s"
+msgid "Resizing volume \"%s\" to %lu sectors."
 msgstr ""
 
-#: report/report.c:1099
-msgid "report_handle pool_zalloc failed"
+#: pvresize.c:207
+msgid "Please supply physical volume(s)"
 msgstr ""
 
-#: report/report.c:1140
-msgid "Allocation of memory pool for report failed"
+#: pvresize.c:224
+#, c-format
+msgid "%d physical volume(s) resized / %d physical volume(s) not resized"
 msgstr ""
 
-#: report/report.c:1157
-msgid "Can't report LV and PV fields at the same time"
+#: pvscan.c:66
+#, c-format
+msgid "PV %-*s    %-*s %s [%s]"
 msgstr ""
 
-#: report/report.c:1198
-msgid "report_object: One of *lv and *pv must be NULL!"
+#: pvscan.c:76
+#, c-format
+msgid "PV %-*s  is in exported VG %s [%s / %s free]"
+msgstr ""
+
+#: pvscan.c:89
+#, c-format
+msgid "PV %-*s VG %-*s %s [%s / %s free]"
 msgstr ""
 
-#: report/report.c:1203
-msgid "struct row allocation failed"
+#: pvscan.c:117
+msgid "Options -e and -n are incompatible"
 msgstr ""
 
-#: report/report.c:1212
-msgid "row sort value structure allocation failed"
+#: pvscan.c:122
+#, c-format
+msgid "WARNING: only considering physical volumes %s"
 msgstr ""
 
-#: report/report.c:1224
-msgid "struct field allocation failed"
+#: pvscan.c:129
+msgid "Walking through all physical volumes"
 msgstr ""
 
-#: report/report.c:1254
-#, c-format
-msgid "report function failed for field %s"
+#: pvscan.c:182
+msgid "No matching physical volumes found"
 msgstr ""
 
-#: report/report.c:1294
-msgid "pool_begin_object failed for headings"
+#: pvscan.c:186
+#, c-format
+msgid "Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]"
 msgstr ""
 
-#: report/report.c:1307
-msgid "snprintf heading failed"
+#: report/report.c:118
+msgid "Extent number dm_snprintf failed"
 msgstr ""
 
-#: report/report.c:1330
-msgid "Failed to generate report headings for printing"
+#: report/report.c:182
+msgid "modules str_list allocation failed"
 msgstr ""
 
-#: report/report.c:1389
-msgid "sort array allocation failed"
+#: report/report.c:259 report/report.c:342 report/report.c:368
+#: report/report.c:466 report/report.c:523 report/report.c:553
+#: report/report.c:694 report/report.c:750 report/report.c:768
+#: report/report.c:793 report/report.c:807
+msgid "dm_pool_alloc failed"
 msgstr ""
 
-#: report/report.c:1432
-msgid "pool_begin_object failed for row"
+#: report/report.c:471
+msgid "lvname snprintf failed"
 msgstr ""
 
-#: report/report.c:1450 report/report.c:1459
-msgid "snprintf repstr failed"
+#: report/report.c:476 report/report.c:518 report/report.c:548
+msgid "dm_pool_strdup failed"
 msgstr ""
 
-#: report/report.c:1474
-msgid "pool_grow_object failed for row"
+#: report/report.c:773
+msgid "snapshot percentage too large"
 msgstr ""
 
-#: report/report.c:1487
-msgid "Failed to generate row for printing"
+#: report/report.c:812
+msgid "copy percentage too large"
 msgstr ""
 
-#: reporter.c:23
+#: reporter.c:24 reporter.c:146 reporter.c:158
 #, c-format
 msgid "Volume group %s not found"
 msgstr ""
 
-#: reporter.c:64 reporter.c:105 toollib.c:236 toollib.c:346
+#: reporter.c:254
 #, c-format
-msgid "Can't lock %s: skipping"
+msgid "Invalid options string: %s"
 msgstr ""
 
-#: reporter.c:69 reporter.c:110
-#, c-format
-msgid "Can't read %s: skipping"
+#: reporter.c:260
+msgid "options string allocation failed"
 msgstr ""
 
-#: reporter.c:212
-#, c-format
-msgid "Invalid options string: %s"
+#: reporter.c:297
+msgid "Can't report LV and PV fields at the same time"
 msgstr ""
 
-#: snapshot/snapshot.c:41
+#: snapshot/snapshot.c:40
 msgid "Couldn't read chunk size for snapshot."
 msgstr ""
 
-#: snapshot/snapshot.c:49
+#: snapshot/snapshot.c:48
 msgid "Snapshot cow storage not specified."
 msgstr ""
 
-#: snapshot/snapshot.c:55
+#: snapshot/snapshot.c:54
 msgid "Snapshot origin not specified."
 msgstr ""
 
-#: snapshot/snapshot.c:62
+#: snapshot/snapshot.c:61
 msgid "Unknown logical volume specified for snapshot cow store."
 msgstr ""
 
-#: snapshot/snapshot.c:68
+#: snapshot/snapshot.c:67
 msgid "Unknown logical volume specified for snapshot origin."
 msgstr ""
 
-#: striped/striped.c:43
+#: snapshot/snapshot.c:135
+msgid "snapshot string list allocation failed"
+msgstr ""
+
+#: striped/striped.c:41
 #, c-format
 msgid "  Stripes\t\t%u"
 msgstr ""
 
-#: striped/striped.c:44
+#: striped/striped.c:42
 #, c-format
 msgid "  Stripe size\t\t%u KB"
 msgstr ""
 
-#: striped/striped.c:47
+#: striped/striped.c:45
 #, c-format
 msgid "  Stripe %d:"
 msgstr ""
 
-#: striped/striped.c:57
+#: striped/striped.c:55
 #, c-format
 msgid "Couldn't read 'stripe_count' for segment '%s'."
 msgstr ""
 
-#: striped/striped.c:72
+#: striped/striped.c:70
 #, c-format
 msgid "Couldn't read stripe_size for segment '%s'."
 msgstr ""
 
-#: striped/striped.c:78
+#: striped/striped.c:76
 #, c-format
 msgid "Couldn't find stripes array for segment '%s'."
 msgstr ""
 
-#: striped/striped.c:175
-msgid "Internal error: striped target with no stripes"
+#: striped/striped.c:163
+#, c-format
+msgid "Internal error: striped add_target_line called with no areas for %s."
 msgstr ""
 
-#: stub.h:20 stub.h:21 stub.h:22
+#: stub.h:24 stub.h:31
 msgid "Command not implemented yet."
 msgstr ""
 
-#: stub.h:25
+#: stub.h:38
 msgid "There's no 'pvdata' command in LVM2."
 msgstr ""
 
-#: stub.h:26
+#: stub.h:39
 msgid ""
 "Use lvs, pvs, vgs instead; or use vgcfgbackup and read the text file backup."
 msgstr ""
 
-#: stub.h:27
+#: stub.h:40
 msgid ""
 "Metadata in LVM1 format can still be displayed using LVM1's pvdata command."
 msgstr ""
 
-#: toollib.c:94
+#: toollib.c:115
+#, c-format
+msgid "skip_dev_dir: Couldn't split up device name %s"
+msgstr ""
+
+#: toollib.c:124 toollib.c:322
+msgid "vg/lv string alloc failed"
+msgstr ""
+
+#: toollib.c:215
 msgid "One or more specified logical volume(s) not found."
 msgstr ""
 
-#: toollib.c:130
+#: toollib.c:251
 msgid "Using logical volume(s) on command line"
 msgstr ""
 
-#: toollib.c:143 toollib.c:399 toollib.c:543 toollib.c:889
+#: toollib.c:264 toollib.c:540 toollib.c:689 toollib.c:1051
 #, c-format
 msgid "Skipping invalid tag %s"
 msgstr ""
 
-#: toollib.c:170 toollib.c:648 toollib.c:659
+#: toollib.c:281 toollib.c:807 toollib.c:818
 #, c-format
 msgid "\"%s\": Invalid path for Logical Volume"
 msgstr ""
 
-#: toollib.c:211
-msgid "vg/lv string alloc failed"
-msgstr ""
-
-#: toollib.c:224
+#: toollib.c:335
 msgid "Finding all logical volumes"
 msgstr ""
 
-#: toollib.c:226 toollib.c:437
+#: toollib.c:337 toollib.c:572
 msgid "No volume groups found"
 msgstr ""
 
-#: toollib.c:246 vgcfgbackup.c:55 vgck.c:22 vgreduce.c:287 vgscan.c:22
+#: toollib.c:357 toollib.c:483 toollib.c:731 vgcfgbackup.c:59 vgck.c:24
+#: vgreduce.c:505 vgscan.c:23
 #, c-format
 msgid "Volume group \"%s\" not found"
 msgstr ""
 
-#: toollib.c:249 vgchange.c:404 vgck.c:27 vgconvert.c:43 vgscan.c:29
+#: toollib.c:369 vgchange.c:523 vgck.c:29 vgconvert.c:43 vgscan.c:30
 #, c-format
 msgid "Volume group \"%s\" inconsistent"
 msgstr ""
 
-#: toollib.c:393
+#: toollib.c:534
 msgid "Using volume group(s) on command line"
 msgstr ""
 
-#: toollib.c:420
+#: toollib.c:555
 #, c-format
 msgid "Invalid volume group name: %s"
 msgstr ""
 
-#: toollib.c:435
+#: toollib.c:570
 msgid "Finding all volume groups"
 msgstr ""
 
-#: toollib.c:559 toollib.c:914
+#: toollib.c:705 toollib.c:1080
 #, c-format
 msgid "Physical Volume \"%s\" not found in Volume Group \"%s\""
 msgstr ""
 
-#: toollib.c:570
+#: toollib.c:716
 #, c-format
 msgid "Failed to read physical volume \"%s\""
 msgstr ""
 
-#: toollib.c:596
+#: toollib.c:755
 msgid "Using all physical volume(s) in volume group"
 msgstr ""
 
-#: toollib.c:666
+#: toollib.c:825
 msgid "Allocation of vg_name failed"
 msgstr ""
 
-#: toollib.c:676
+#: toollib.c:835
 #, c-format
 msgid "Path required for Logical Volume \"%s\""
 msgstr ""
 
-#: toollib.c:707
+#: toollib.c:858
 #, c-format
 msgid "Environment Volume Group in LVM_VG_NAME invalid: \"%s\""
 msgstr ""
 
-#: toollib.c:723
+#: toollib.c:874
 #, c-format
-msgid "Adding PE range: start PE %u length %u"
+msgid "Adding PE range: start PE %u length %u on %s"
 msgstr ""
 
-#: toollib.c:731
+#: toollib.c:882
 #, c-format
-msgid "Overlapping PE ranges detected (%u-%u, %u-%u)"
+msgid "Overlapping PE ranges specified (%u-%u, %u-%u) on %s"
 msgstr ""
 
-#: toollib.c:740 toollib.c:877 toollib.c:934
+#: toollib.c:892 toollib.c:1039 toollib.c:1103
 msgid "Allocation of list failed"
 msgstr ""
 
-#: toollib.c:804
+#: toollib.c:956
 #, c-format
 msgid "PE range error: start extent %u to end extent %u"
 msgstr ""
 
-#: toollib.c:819
+#: toollib.c:971
 #, c-format
 msgid "Physical extent parsing error at %s"
 msgstr ""
 
-#: toollib.c:832
+#: toollib.c:984
 #, c-format
 msgid "Physical volume %s not allocatable"
 msgstr ""
 
-#: toollib.c:838
+#: toollib.c:990
 #, c-format
 msgid "No free extents on physical volume \"%s\""
 msgstr ""
 
-#: toollib.c:843 toollib.c:941
+#: toollib.c:1002 toollib.c:1110
 msgid "Unable to allocate physical volume list."
 msgstr ""
 
-#: toollib.c:850
+#: toollib.c:1009
 msgid "Allocation of pe_ranges list failed"
 msgstr ""
 
-#: toollib.c:922
+#: toollib.c:1091
 msgid "No specified PVs have space available"
 msgstr ""
 
-#: toollib.c:964
+#: toollib.c:1137
 #, c-format
 msgid "Can't lock %s for metadata recovery: skipping"
 msgstr ""
 
-#: toollib.c:981
+#: toollib.c:1148
+msgid ""
+"Names starting \"snapshot\" are reserved. Please choose a different LV name."
+msgstr ""
+
+#: toollib.c:1154
+msgid ""
+"Names starting \"pvmove\" are reserved. Please choose a different LV name."
+msgstr ""
+
+#: toollib.c:1160
+msgid ""
+"Names including \"_mlog\" are reserved. Please choose a different LV name."
+msgstr ""
+
+#: toollib.c:1166
+msgid ""
+"Names including \"_mimage\" are reserved. Please choose a different LV name."
+msgstr ""
+
+#: toollib.c:1183
 #, c-format
-msgid "Executing: %s %s %s %s"
+msgid "%s: already exists in filesystem"
+msgstr ""
+
+#: toollib.c:1227
+msgid "Name allocation failed - device not cleared"
 msgstr ""
 
-#: toollib.c:998
+#: toollib.c:1233
 #, c-format
-msgid "wait4 child process %u failed: %s"
+msgid "Name too long - device not cleared (%s)"
 msgstr ""
 
-#: toollib.c:1004
+#: toollib.c:1237
 #, c-format
-msgid "Child %u exited abnormally"
+msgid "Clearing start of logical volume \"%s\""
 msgstr ""
 
-#: toollib.c:1009
+#: toollib.c:1240
 #, c-format
-msgid "%s failed: %u"
+msgid "%s: not found: device not cleared"
 msgstr ""
 
-#: toollib.c:1019
-msgid ""
-"Names starting \"snapshot\" are reserved. Please choose a different LV name."
+#: toollib.c:1276
+#, c-format
+msgid "Name allocation failed - log header not written (%s)"
 msgstr ""
 
-#: toollib.c:1025
-msgid ""
-"Names starting \"pvmove\" are reserved. Please choose a different LV name."
+#: toollib.c:1283
+#, c-format
+msgid "Name too long - log header not written (%s)"
 msgstr ""
 
-#: toollib.c:1031
-msgid ""
-"Names including \"_mlog\" are reserved. Please choose a different LV name."
+#: toollib.c:1287
+#, c-format
+msgid "Writing log header to device, %s"
 msgstr ""
 
-#: toollib.c:1037
-msgid ""
-"Names including \"_mimage\" are reserved. Please choose a different LV name."
+#: toollib.c:1290
+#, c-format
+msgid "%s: not found: log header not written"
 msgstr ""
 
-#: toollib.c:1054
+#: toollib.c:1298
 #, c-format
-msgid "%s: already exists in filesystem"
+msgid "Failed to write log header to %s"
 msgstr ""
 
-#: toollib.c:1077
-msgid "Name allocation failed - device not zeroed"
+#: toollib.c:1324
+msgid "log_name allocation failed. Remove new LV and retry."
 msgstr ""
 
-#: toollib.c:1083
-#, c-format
-msgid "Name too long - device not zeroed (%s)"
+#: toollib.c:1344
+msgid "Aborting. Unable to tag mirror log."
 msgstr ""
 
-#: toollib.c:1087
-#, c-format
-msgid "Zeroing start of logical volume \"%s\""
+#: toollib.c:1362
+msgid ""
+"Aborting. Unable to create in-sync mirror log while activation is disabled."
+msgstr ""
+
+#: toollib.c:1368
+msgid "Aborting. Failed to activate mirror log. Remove new LVs and retry."
 msgstr ""
 
-#: toollib.c:1090
+#: toollib.c:1375
 #, c-format
-msgid "%s: not found: device not zeroed"
+msgid "Failed to remove tag %s from mirror log."
 msgstr ""
 
-#: uuid/uuid.c:133
+#: toollib.c:1380
+msgid "Aborting. Failed to wipe mirror log. Remove new LV and retry."
+msgstr ""
+
+#: toollib.c:1386
+msgid "Aborting. Failed to write mirror log header. Remove new LV and retry."
+msgstr ""
+
+#: toollib.c:1392
+msgid "Aborting. Failed to deactivate mirror log. Remove new LV and retry."
+msgstr ""
+
+#: uuid/uuid.c:132
 msgid "UUID contains invalid character"
 msgstr ""
 
-#: uuid/uuid.c:157
+#: uuid/uuid.c:156
 msgid "Couldn't write uuid, buffer too small."
 msgstr ""
 
-#: uuid/uuid.c:185
+#: uuid/uuid.c:184
 msgid "Too many characters to be uuid."
 msgstr ""
 
-#: uuid/uuid.c:193
+#: uuid/uuid.c:192
 msgid "Couldn't read uuid, incorrect number of characters."
 msgstr ""
 
-#: vgcfgbackup.c:28
+#: vgcfgbackup.c:27
+msgid "Failed to allocate filename."
+msgstr ""
+
+#: vgcfgbackup.c:32
 #, c-format
 msgid "Error processing filename template %s"
 msgstr ""
 
-#: vgcfgbackup.c:35
+#: vgcfgbackup.c:39
 #, c-format
 msgid ""
 "VGs must be backed up into different files. Use %%s in filename for VG name."
 msgstr ""
 
-#: vgcfgbackup.c:60
+#: vgcfgbackup.c:64
 #, c-format
 msgid "Warning: Volume group \"%s\" inconsistent"
 msgstr ""
 
-#: vgcfgbackup.c:72
+#: vgcfgbackup.c:76
 msgid "No backup taken: specify filename with -f to backup an inconsistent VG"
 msgstr ""
 
-#: vgcfgbackup.c:86
+#: vgcfgbackup.c:90
 #, c-format
 msgid "Volume group \"%s\" successfully backed up."
 msgstr ""
@@ -6168,180 +6846,212 @@
 msgid "Please specify a *single* volume group to restore."
 msgstr ""
 
-#: vgcfgrestore.c:33
+#: vgcfgrestore.c:30 vgextend.c:45 vgreduce.c:469 vgsplit.c:228
 #, c-format
 msgid "Volume group name \"%s\" is invalid"
 msgstr ""
 
-#: vgcfgrestore.c:49
+#: vgcfgrestore.c:46
 msgid "Unable to lock orphans"
 msgstr ""
 
-#: vgcfgrestore.c:54
+#: vgcfgrestore.c:51
 #, c-format
 msgid "Unable to lock volume group %s"
 msgstr ""
 
-#: vgcfgrestore.c:65
+#: vgcfgrestore.c:62
 msgid "Restore failed."
 msgstr ""
 
-#: vgcfgrestore.c:69
+#: vgcfgrestore.c:66
 #, c-format
 msgid "Restored volume group %s"
 msgstr ""
 
-#: vgchange.c:56
+#: vgchange.c:92
 #, c-format
 msgid "Spawning background process for %s %s"
 msgstr ""
 
-#: vgchange.c:81
+#: vgchange.c:111
+#, c-format
+msgid "%d logical volume(s) in volume group \"%s\" %smonitored"
+msgstr ""
+
+#: vgchange.c:132
 #, c-format
 msgid "Can't deactivate volume group \"%s\" with %d open logical volume(s)"
 msgstr ""
 
-#: vgchange.c:87
+#: vgchange.c:138
 #, c-format
 msgid "Locking inactive: ignoring clustered volume group %s"
 msgstr ""
 
-#: vgchange.c:97
+#: vgchange.c:148
 #, c-format
 msgid "%d logical volume(s) in volume group \"%s\" already active"
 msgstr ""
 
-#: vgchange.c:101
+#: vgchange.c:152
+#, c-format
+msgid "%d existing logical volume(s) in volume group \"%s\" %smonitored"
+msgstr ""
+
+#: vgchange.c:160
 #, c-format
 msgid "Activated logical volumes in volume group \"%s\""
 msgstr ""
 
-#: vgchange.c:105
+#: vgchange.c:164
 #, c-format
 msgid "Deactivated logical volumes in volume group \"%s\""
 msgstr ""
 
-#: vgchange.c:108
+#: vgchange.c:167
 #, c-format
 msgid "%d logical volume(s) in volume group \"%s\" now active"
 msgstr ""
 
-#: vgchange.c:120 vgcreate.c:47
+#: vgchange.c:179 vgcreate.c:47
 msgid "Volume Group allocation policy cannot inherit from anything"
 msgstr ""
 
-#: vgchange.c:126
+#: vgchange.c:185
 #, c-format
 msgid "Volume group allocation policy is already %s"
 msgstr ""
 
-#: vgchange.c:141 vgchange.c:176 vgchange.c:211 vgchange.c:253 vgchange.c:311
-#: vgchange.c:353 vgchange.c:385
+#: vgchange.c:200 vgchange.c:235 vgchange.c:282 vgchange.c:324 vgchange.c:371
+#: vgchange.c:429 vgchange.c:471 vgchange.c:504
 #, c-format
 msgid "Volume group \"%s\" successfully changed"
 msgstr ""
 
-#: vgchange.c:152
+#: vgchange.c:211
 #, c-format
 msgid "Volume group \"%s\" is already resizeable"
 msgstr ""
 
-#: vgchange.c:158
+#: vgchange.c:217
 #, c-format
 msgid "Volume group \"%s\" is already not resizeable"
 msgstr ""
 
-#: vgchange.c:187
+#: vgchange.c:247
 #, c-format
 msgid "Volume group \"%s\" is already clustered"
 msgstr ""
 
-#: vgchange.c:193
+#: vgchange.c:253
 #, c-format
 msgid "Volume group \"%s\" is already not clustered"
 msgstr ""
 
-#: vgchange.c:222
+#: vgchange.c:261
+#, c-format
+msgid "Volume group %s contains snapshots that are not yet supported."
+msgstr ""
+
+#: vgchange.c:293
 #, c-format
 msgid "Volume group \"%s\" must be resizeable to change MaxLogicalVolume"
 msgstr ""
 
-#: vgchange.c:231
+#: vgchange.c:302
 msgid "MaxLogicalVolume limit is 255"
 msgstr ""
 
-#: vgchange.c:237
+#: vgchange.c:308
 #, c-format
-msgid ""
-"MaxLogicalVolume is less than the current number %d of logical volume(s) for "
-"\"%s\""
+msgid "MaxLogicalVolume is less than the current number %d of LVs for \"%s\""
+msgstr ""
+
+#: vgchange.c:335
+#, c-format
+msgid "Volume group \"%s\" must be resizeable to change MaxPhysicalVolumes"
+msgstr ""
+
+#: vgchange.c:341
+msgid "MaxPhysicalVolumes may not be negative"
+msgstr ""
+
+#: vgchange.c:349
+msgid "MaxPhysicalVolume limit is 255"
+msgstr ""
+
+#: vgchange.c:355
+#, c-format
+msgid "MaxPhysicalVolumes is less than the current number %d of PVs for \"%s\""
 msgstr ""
 
-#: vgchange.c:263
+#: vgchange.c:381
 #, c-format
 msgid "Volume group \"%s\" must be resizeable to change PE size"
 msgstr ""
 
-#: vgchange.c:269 vgcreate.c:64
+#: vgchange.c:387 vgcreate.c:64
 msgid "Physical extent size may not be negative"
 msgstr ""
 
-#: vgchange.c:275 vgcreate.c:83
+#: vgchange.c:393 vgcreate.c:83
 msgid "Physical extent size may not be zero"
 msgstr ""
 
-#: vgchange.c:280
+#: vgchange.c:398
 #, c-format
 msgid "Physical extent size of VG %s is already %s"
 msgstr ""
 
-#: vgchange.c:286
+#: vgchange.c:404
 msgid "Physical extent size must be a power of 2."
 msgstr ""
 
-#: vgchange.c:293
+#: vgchange.c:411
 msgid "New extent size is not a perfect fit"
 msgstr ""
 
-#: vgchange.c:336 vgcreate.c:121
+#: vgchange.c:454 vgcreate.c:117
 #, c-format
 msgid "Failed to add tag %s to volume group %s"
 msgstr ""
 
-#: vgchange.c:342
+#: vgchange.c:460
 #, c-format
 msgid "Failed to remove tag %s from volume group %s"
 msgstr ""
 
-#: vgchange.c:363
+#: vgchange.c:482
 msgid "Volume group has active logical volumes"
 msgstr ""
 
-#: vgchange.c:371
+#: vgchange.c:490
 #, c-format
 msgid "Failed to generate new random UUID for VG %s."
 msgstr ""
 
-#: vgchange.c:397 vgconvert.c:36 vgexport.c:23
+#: vgchange.c:516 vgconvert.c:36 vgexport.c:27
 #, c-format
 msgid "Unable to find volume group \"%s\""
 msgstr ""
 
-#: vgchange.c:457
+#: vgchange.c:588
 msgid ""
-"One of -a, -c, -l, -s, -x, --uuid, --alloc, --addtag or --deltag required"
+"One of -a, -c, -l, -p, -s, -x, --uuid, --alloc, --addtag or --deltag required"
 msgstr ""
 
-#: vgchange.c:468
+#: vgchange.c:600
 msgid ""
-"Only one of -a, -c, -l, -s, -x, --uuid, --alloc, --addtag or --deltag allowed"
+"Only one of -a, -c, -l, -p, -s, -x, --uuid, --alloc, --addtag or --deltag "
+"allowed"
 msgstr ""
 
-#: vgchange.c:475
+#: vgchange.c:607
 msgid "--ignorelockingfailure only available with -a"
 msgstr ""
 
-#: vgchange.c:481
+#: vgchange.c:613
 msgid "-A option not necessary with -a option"
 msgstr ""
 
@@ -6419,26 +7129,26 @@
 msgid "Max Physical Volumes may not be negative"
 msgstr ""
 
-#: vgcreate.c:92 vgrename.c:55 vgsplit.c:226
+#: vgcreate.c:88 vgrename.c:52 vgsplit.c:290
 #, c-format
 msgid "New volume group name \"%s\" is invalid"
 msgstr ""
 
-#: vgcreate.c:102
+#: vgcreate.c:98
 #, c-format
 msgid "Warning: Setting maxlogicalvolumes to %d (0 means unlimited)"
 msgstr ""
 
-#: vgcreate.c:106
+#: vgcreate.c:102
 #, c-format
 msgid "Warning: Setting maxphysicalvolumes to %d (0 means unlimited)"
 msgstr ""
 
-#: vgcreate.c:116
+#: vgcreate.c:112
 msgid "Volume group format does not support tags"
 msgstr ""
 
-#: vgcreate.c:167
+#: vgcreate.c:163
 #, c-format
 msgid "Volume group \"%s\" successfully created"
 msgstr ""
@@ -6465,31 +7175,31 @@
 msgid "Option -A is not allowed with volume group names"
 msgstr ""
 
-#: vgexport.c:28
+#: vgexport.c:32
 #, c-format
 msgid "Volume group %s inconsistent"
 msgstr ""
 
-#: vgexport.c:33
+#: vgexport.c:37
 #, c-format
 msgid "Volume group \"%s\" is already exported"
 msgstr ""
 
-#: vgexport.c:43
+#: vgexport.c:47
 #, c-format
 msgid "Volume group \"%s\" has active logical volumes"
 msgstr ""
 
-#: vgexport.c:58
+#: vgexport.c:67
 #, c-format
 msgid "Volume group \"%s\" successfully exported"
 msgstr ""
 
-#: vgexport.c:69 vgimport.c:59
+#: vgexport.c:78 vgimport.c:68
 msgid "Please supply volume groups or use -a for all."
 msgstr ""
 
-#: vgexport.c:74 vgimport.c:64
+#: vgexport.c:83 vgimport.c:73
 msgid "No arguments permitted when using -a for all."
 msgstr ""
 
@@ -6501,207 +7211,247 @@
 msgid "Please enter physical volume(s)"
 msgstr ""
 
-#: vgextend.c:44 vgmerge.c:31 vgmerge.c:55 vgsplit.c:187 vgsplit.c:211
+#: vgextend.c:50 vgmerge.c:32 vgmerge.c:63 vgsplit.c:238 vgsplit.c:275
 #, c-format
 msgid "Checking for volume group \"%s\""
 msgstr ""
 
-#: vgextend.c:52
+#: vgextend.c:58
 #, c-format
 msgid "Volume group \"%s\" not found."
 msgstr ""
 
-#: vgextend.c:67
+#: vgextend.c:79
 #, c-format
 msgid "Volume group \"%s\" is not resizeable."
 msgstr ""
 
-#: vgextend.c:86
+#: vgextend.c:98
 #, c-format
 msgid "Volume group \"%s\" will be extended by %d new physical volumes"
 msgstr ""
 
-#: vgextend.c:98
+#: vgextend.c:110
 #, c-format
 msgid "Volume group \"%s\" successfully extended"
 msgstr ""
 
-#: vgimport.c:23
+#: vgimport.c:27
 #, c-format
 msgid "Unable to find exported volume group \"%s\""
 msgstr ""
 
-#: vgimport.c:29
+#: vgimport.c:33
 #, c-format
 msgid "Volume group \"%s\" is not exported"
 msgstr ""
 
-#: vgimport.c:34
+#: vgimport.c:38
 #, c-format
 msgid "Volume group \"%s\" is partially missing"
 msgstr ""
 
-#: vgimport.c:48
+#: vgimport.c:57
 #, c-format
 msgid "Volume group \"%s\" successfully imported"
 msgstr ""
 
-#: vgmerge.c:27 vgsplit.c:183
+#: vgmerge.c:28 vgsplit.c:234
 #, c-format
 msgid "Duplicate volume group name \"%s\""
 msgstr ""
 
-#: vgmerge.c:79 vgsplit.c:233
+#: vgmerge.c:93 vgsplit.c:297
 #, c-format
 msgid "Logical volumes in \"%s\" must be inactive"
 msgstr ""
 
-#: vgmerge.c:86
+#: vgmerge.c:100
 #, c-format
 msgid "Extent sizes differ: %d (%s) and %d (%s)"
 msgstr ""
 
-#: vgmerge.c:94
+#: vgmerge.c:108
 #, c-format
 msgid "Maximum number of physical volumes (%d) exceeded  for \"%s\" and \"%s\""
 msgstr ""
 
-#: vgmerge.c:102
+#: vgmerge.c:116
 #, c-format
 msgid "Maximum number of logical volumes (%d) exceeded  for \"%s\" and \"%s\""
 msgstr ""
 
-#: vgmerge.c:116
+#: vgmerge.c:130
 #, c-format
 msgid "Duplicate logical volume name \"%s\" in \"%s\" and \"%s\""
 msgstr ""
 
-#: vgmerge.c:153
+#: vgmerge.c:142 vgmerge.c:151
+#, c-format
+msgid "Physical volume %s might be constructed from same volume group %s."
+msgstr ""
+
+#: vgmerge.c:186
 #, c-format
 msgid "Failed to generate new random LVID for %s"
 msgstr ""
 
-#: vgmerge.c:164
+#: vgmerge.c:197
 #, c-format
 msgid "Changed LVID for %s to %s"
 msgstr ""
 
-#: vgmerge.c:202
+#: vgmerge.c:235
 #, c-format
 msgid "Volume group \"%s\" successfully merged into \"%s\""
 msgstr ""
 
-#: vgmerge.c:219
+#: vgmerge.c:252
 msgid "Please enter 2 or more volume groups to merge"
 msgstr ""
 
-#: vgreduce.c:23
+#: vgreduce.c:24
 msgid "Volume Groups must always contain at least one PV"
 msgstr ""
 
-#: vgreduce.c:32
+#: vgreduce.c:33
 #, c-format
 msgid "Removing PV with UUID %s from VG %s"
 msgstr ""
 
-#: vgreduce.c:35
+#: vgreduce.c:36
 #, c-format
 msgid "LVs still present on PV with UUID %s: Can't remove from VG %s"
 msgstr ""
 
-#: vgreduce.c:56
+#: vgreduce.c:61
 #, c-format
 msgid "%s/%s has missing extents: removing (including dependencies)"
 msgstr ""
 
-#: vgreduce.c:61
+#: vgreduce.c:68
 #, c-format
-msgid "Deactivating (if active) logical volume %s"
+msgid "Deactivating (if active) logical volume %s (origin of %s)"
 msgstr ""
 
-#: vgreduce.c:65 vgreduce.c:73
+#: vgreduce.c:72 vgreduce.c:89 vgreduce.c:333
 #, c-format
 msgid "Failed to deactivate LV %s"
 msgstr ""
 
-#: vgreduce.c:69
+#: vgreduce.c:99 vgreduce.c:146 vgreduce.c:348
 #, c-format
-msgid "Deactivating (if active) logical volume %s (origin of %s)"
+msgid "Removing LV %s from VG %s"
 msgstr ""
 
-#: vgreduce.c:93 vgreduce.c:102
+#: vgreduce.c:191
 #, c-format
-msgid "Removing LV %s from VG %s"
+msgid "Non-mirror-image LV %s found: can't remove."
+msgstr ""
+
+#: vgreduce.c:207
+msgid "Aborting because --mirrorsonly was specified."
+msgstr ""
+
+#: vgreduce.c:232 vgreduce.c:529
+#, c-format
+msgid "Failed to write out a consistent VG for %s"
+msgstr ""
+
+#: vgreduce.c:250
+#, c-format
+msgid "Failed to commit consistent VG for %s"
+msgstr ""
+
+#: vgreduce.c:258
+msgid "Failed to resume LVs using error segments."
+msgstr ""
+
+#: vgreduce.c:290
+#, c-format
+msgid "The log device for %s/%s has failed."
 msgstr ""
 
-#: vgreduce.c:172
+#: vgreduce.c:296
+#, c-format
+msgid "Log device for %s/%s has failed."
+msgstr ""
+
+#: vgreduce.c:312
+#, c-format
+msgid "Failed to write out updated VG for %s"
+msgstr ""
+
+#: vgreduce.c:318
+#, c-format
+msgid "Failed to commit updated VG for %s"
+msgstr ""
+
+#: vgreduce.c:329
+#, c-format
+msgid "Deactivating (if active) logical volume %s"
+msgstr ""
+
+#: vgreduce.c:371
 #, c-format
 msgid "Physical volume \"%s\" still in use"
 msgstr ""
 
-#: vgreduce.c:177
+#: vgreduce.c:376
 #, c-format
 msgid "Can't remove final physical volume \"%s\" from volume group \"%s\""
 msgstr ""
 
-#: vgreduce.c:187
+#: vgreduce.c:386
 #, c-format
 msgid "Removing \"%s\" from volume group \"%s\""
 msgstr ""
 
-#: vgreduce.c:205
+#: vgreduce.c:404
 #, c-format
 msgid "Removal of physical volume \"%s\" from \"%s\" failed"
 msgstr ""
 
-#: vgreduce.c:211
-#, c-format
-msgid ""
-"Failed to clear metadata from physical volume \"%s\" after removal from \"%s"
-"\""
-msgstr ""
-
-#: vgreduce.c:219
+#: vgreduce.c:418
 #, c-format
 msgid "Removed \"%s\" from volume group \"%s\""
 msgstr ""
 
-#: vgreduce.c:232
+#: vgreduce.c:431
 msgid "Please give volume group name and physical volume paths"
 msgstr ""
 
-#: vgreduce.c:238
+#: vgreduce.c:437
 msgid "Please give volume group name"
 msgstr ""
 
-#: vgreduce.c:244
+#: vgreduce.c:443
+msgid "--mirrorsonly requires --removemissing"
+msgstr ""
+
+#: vgreduce.c:449
 msgid "Please enter physical volume paths or option -a"
 msgstr ""
 
-#: vgreduce.c:249
+#: vgreduce.c:454
 msgid "Option -a and physical volume paths mutually exclusive"
 msgstr ""
 
-#: vgreduce.c:255
+#: vgreduce.c:460
 msgid "Please only specify the volume group"
 msgstr ""
 
-#: vgreduce.c:278
+#: vgreduce.c:496
 #, c-format
 msgid "Volume group \"%s\" is already consistent"
 msgstr ""
 
-#: vgreduce.c:309
-#, c-format
-msgid "Failed to write out a consistent VG for %s"
-msgstr ""
-
-#: vgreduce.c:317
+#: vgreduce.c:537
 #, c-format
 msgid "Wrote out consistent volume group %s"
 msgstr ""
 
-#: vgreduce.c:333
+#: vgreduce.c:553
 #, c-format
 msgid "Volume group \"%s\" is not reducible"
 msgstr ""
@@ -6745,63 +7495,81 @@
 msgid "Volume group \"%s\" not properly removed"
 msgstr ""
 
-#: vgrename.c:31
+#: vgremove.c:91
+msgid "Please enter one or more volume group paths"
+msgstr ""
+
+#: vgrename.c:34
 msgid "Old and new volume group names need specifying"
 msgstr ""
 
-#: vgrename.c:49
+#: vgrename.c:46
 #, c-format
 msgid "New volume group path exceeds maximum length of %d!"
 msgstr ""
 
-#: vgrename.c:61
+#: vgrename.c:58
 msgid "Old and new volume group names must differ"
 msgstr ""
 
-#: vgrename.c:92
+#: vgrename.c:66
+msgid "No complete volume groups found"
+msgstr ""
+
+#: vgrename.c:76
+#, c-format
+msgid "Found more than one VG called %s. Please supply VG uuid."
+msgstr ""
+
+#: vgrename.c:99
+#, c-format
+msgid "Volume group %s %s%s%snot found."
+msgstr ""
+
+#: vgrename.c:123
 #, c-format
 msgid "Volume group \"%s\" still has active LVs"
 msgstr ""
 
-#: vgrename.c:98
+#: vgrename.c:129
 #, c-format
 msgid "Checking for new volume group \"%s\""
 msgstr ""
 
-#: vgrename.c:108
+#: vgrename.c:139
 #, c-format
 msgid "New volume group \"%s\" already exists"
 msgstr ""
 
-#: vgrename.c:123
+#: vgrename.c:154
 #, c-format
 msgid "Renaming \"%s\" to \"%s\""
 msgstr ""
 
-#: vgrename.c:125
+#: vgrename.c:156
 msgid "Test mode: Skipping rename."
 msgstr ""
 
-#: vgrename.c:127
+#: vgrename.c:158
 #, c-format
 msgid "Renaming \"%s\" to \"%s\" failed: %s"
 msgstr ""
 
-#: vgrename.c:146
+#: vgrename.c:177
 #, c-format
 msgid "Volume group \"%s\" successfully renamed to \"%s\""
 msgstr ""
 
-#: vgscan.c:35
+#: vgscan.c:36
 #, c-format
 msgid "Found %svolume group \"%s\" using metadata type %s"
 msgstr ""
 
-#: vgscan.c:49
+#: vgscan.c:50
 msgid "Too many parameters on command line"
 msgstr ""
 
-#: vgscan.c:56
+#: vgscan.c:57
 msgid "Reading all physical volumes.  This may take a while..."
 msgstr ""
 
@@ -6810,40 +7578,53 @@
 msgid "Physical volume %s not in volume group %s"
 msgstr ""
 
-#: vgsplit.c:87
+#: vgsplit.c:90
 #, c-format
-msgid "Logical Volume %s split between Volume Groups"
+msgid "Can't split Logical Volume %s between two Volume Groups"
 msgstr ""
 
-#: vgsplit.c:104
+#: vgsplit.c:152
 #, c-format
-msgid "Physical Volume %s not found"
+msgid "Snapshot %s split"
 msgstr ""
 
-#: vgsplit.c:149
+#: vgsplit.c:193
 #, c-format
-msgid "Snapshot %s split"
+msgid "Mirror %s split"
 msgstr ""
 
-#: vgsplit.c:173
+#: vgsplit.c:218
 msgid "Existing VG, new VG and physical volumes required."
 msgstr ""
 
-#: vgsplit.c:221
+#: vgsplit.c:264
+#, c-format
+msgid "Volume group \"%s\" is not resizeable"
+msgstr ""
+
+#: vgsplit.c:285
 #, c-format
 msgid "Volume group \"%s\" already exists"
 msgstr ""
 
-#: vgsplit.c:269
+#: vgsplit.c:339
+msgid "Cannot split: Nowhere to store metadata for new Volume Group"
+msgstr ""
+
+#: vgsplit.c:348
 msgid "Writing out updated volume groups"
 msgstr ""
 
-#: vgsplit.c:291
+#: vgsplit.c:370
 #, c-format
 msgid "Volume group \"%s\" became inconsistent: please fix manually"
 msgstr ""
 
-#: vgsplit.c:306
+#: vgsplit.c:385
 #, c-format
 msgid "Volume group \"%s\" successfully split from \"%s\""
 msgstr ""
+
+#: zero/zero.c:71
+msgid "zero module string list allocation failed"
+msgstr ""


