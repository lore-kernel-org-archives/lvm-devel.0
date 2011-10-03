From: ben <benscott@nwlink.com>
Date: Sun, 02 Oct 2011 23:13 -0700
Subject: vgsplit fails with mirrored mirror log
Message-ID: <2560390.Z1BDMnrLph@laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


vgsplit fails with mirrored mirror log

#lvs --all -o lv_name,lv_attr,devices
  LV                       Attr   Devices                                                       
  MyMirror                 mwi--
  [MyMirror_mimage_0]      Iwi--- /dev/sdq(0)                                                   
  [MyMirror_mimage_1]      Iwi--- /dev/sdo(0)                                                   
  [MyMirror_mimage_2]      Iwi--- /dev/sdi(0)                                                   
  [MyMirror_mlog]          mwi---            
  [MyMirror_mlog_mimage_0] Iwi--- /dev/sds(0)                                                   
  [MyMirror_mlog_mimage_1] Iwi--- /dev/sde(0)                                                   

#vgsplit -v "TestA" "TestB" "/dev/sdq" "/dev/sdo" "/dev/sdi" "/dev/sds" 
"/dev/sde"
    Checking for volume group "TestA"
    Checking for new volume group "TestB"
    Archiving volume group "TestA" metadata (seqno 213).
  Can't split mirror MyMirror between two Volume Groups



If I reduce it to a single mirror log it splits as expected.


