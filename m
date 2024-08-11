Received: from mout.gmx.net (mout.gmx.net [212.227.17.21])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9DE5320322
	for <lvm-devel@lists.linux.dev>; Sun, 11 Aug 2024 09:05:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.17.21
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1723367110; cv=none; b=bmBAf6beRgvtXQbJgDhBjGkLq1dxFRtOjTFybjfZLnLZ4b589luBfeCMmC1Tb/QFSjqX3ENRcqn9kVvAVuZHHtIVPU07CMHXfODhhbAbpTzrLVkhVxiu4vo9RBBj7Ve6UILcynS6nmYqoZkHtdcnCVIU2Zcsy+jfPfqpr0J2oIs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1723367110; c=relaxed/simple;
	bh=1Bzj7o+uCxAHX2Au66/aNQNeDPAPr8hltoFQDVERYq0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=CtcbYXjKqUp+tKWndiE+d64DyuFHMh2V94zNZqjnJw9zA9/ipfkAgS7QFlIZfRTtVsMX2wGkbMEcXhuIVSVw2PHbsNhlXkHOoabqaWWU/qaC0dQ/wh6j1NZKS+6MnIqs0pu57WgKEQ9R2Tbejpa7TLlrYERlfEQRbfA8jKgwLHE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=j.neuschaefer@gmx.net header.b=ScCpvPN0; arc=none smtp.client-ip=212.227.17.21
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=j.neuschaefer@gmx.net header.b="ScCpvPN0"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1723367093; x=1723971893; i=j.neuschaefer@gmx.net;
	bh=PQoK75LGskjImgHPQvMqpAYAVpmyezFeIkSz//GmB+g=;
	h=X-UI-Sender-Class:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:To:Cc:cc:
	 content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=ScCpvPN0vllp5kHLS68qLVRljJ/LwHaCbg/dThlyHLqomA/ssMA9qSoc29mOtYCp
	 LFlbu5EYepNqHFu4vWG7aJPdpLTyGRAPwU/H4zXdO62Rs50NKws66X9cnPyw41m92
	 NqTW43A+dWvqIxlO81o48r5AnjClOn6CwLkf/5bixVIiWOK2iZRP2M0BUsS2q7C/M
	 QgCuh5ZFAZgR6DYIEgPw8DKK5+xc9YuZu6f64q+HmJXHb+danwN5NcZpFX17Lr/0N
	 aPoIp3UQw3o+5oQldYEnvrR85rPkaR8LjJ8NWH/RneSCYOFToSZf28d2nG3j+aIU4
	 +M8zoLnXhqoELPC2hg==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from probook ([89.0.46.195]) by mail.gmx.net (mrgmx104
 [212.227.17.168]) with ESMTPSA (Nemesis) id 1M4axq-1seiOp1kQA-003fyT; Sun, 11
 Aug 2024 11:04:53 +0200
From: =?utf-8?q?J=2E_Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Date: Sun, 11 Aug 2024 11:04:38 +0200
Subject: [PATCH lvm2] acinclude.m4: Link when trying CCFLAGS
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <20240811-microblaze-v1-1-2781ba343e75@gmx.net>
X-B4-Tracking: v=1; b=H4sIAKV+uGYC/x3MTQqAIBBA4avErBMciZKuEi2sxhrwJxQiku6et
 PwW7xXIlJgyjE2BRBdnjqEC2wbWw4SdBG/VoKTqpEYUntcUF2ceEtpabXqFQzcg1OBMZPn+ZxO
 4yyuY3/cDl4LOmWIAAAA=
To: lvm-devel@lists.linux.dev
Cc: buildroot@buildroot.org, musl@lists.openwall.com, 
 =?utf-8?q?J=2E_Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1723367092; l=2401;
 i=j.neuschaefer@gmx.net; s=20240329; h=from:subject:message-id;
 bh=/jIoqjC9HzN9jLlhBHdisfW2C1WpRbO4792I/s/913g=;
 b=3Zs9la8ZPyPtID4e77odGCPmIitjOeoQRKnvgzCh+GYHSl1NO6PfHOlZc14IJUctSdFx5ryBT
 JfoK1xujQf7BRvqmI09W2XWSp+LZ9epalzwru0h+BCOtMI7kLRxzdja
X-Developer-Key: i=j.neuschaefer@gmx.net; a=ed25519;
 pk=NIe0bK42wNaX/C4bi6ezm7NJK0IQE+8MKBm7igFMIS4=
X-Provags-ID: V03:K1:WOrrRbzpFtEMi6+1crbbcGv0FhIPJkq1p9+4LxfFPYtoSA9Etpa
 tTiU7LaOYmadEx7uDoVmvJy5iOXUxCgKMe5ZreARuLtQSeNRhGMtmWYV3qRWRH/w+gJVVM3
 lBtl1q/1XCy3uptSiiNTmVYAtjS986oMGjmxGoaFMCb2RLjM+zfcrC6Yau22zmp9OkLXmB3
 EchULdjLJiHRDb6vth7Yw==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:H8rBUuTISr8=;IHCswTQfM4hlCWRaYt/Kdbx//Kp
 nv1uBpbPWEIrnTEAlmQ6eqiXZw33Qs1ug8oiwd7I053YHQ22JXVv11Rh1DT0Tu4Iqqt+Qjoig
 6tKnTuMy7bcCjakg4hRQc/0DqlDoPC8FZJE3oaHOV4tOpkOQ3ShTfB+n528Wcrd+GTsb3EaVf
 J91vkpVTTdntdwGF8JpX3bup8Dd0CYuM57I9AEKWHHXSNiTaSg+iJbrQMOm81WS3C3vohVRPx
 fQuOMVVhtmkicMWX/iM+ig9hvzM1ZzJ6IjCw55xSpPhijmkF1IDSSgV7kCsmSh3Et7A8NVLs7
 yNSWXMBBCGwj1V1pe1G1KhRJjyLKZE7fhhet8SZvo/k68ha0UkdajaHGohpEpHUXEoqb4LtbA
 jbz5cbwh3uUa6aRyU+UWfrr0Tk5bfVQM3IW6CH6phVIShGAeHEasUMpv513bKCwXV/whjYuK5
 DzafK2dN3o8wAJBKmRxm4XQ479C2Ll4QJYRTjqnxNa8dAnsBZ8gzXdCGS9/JZMsbD0uXBOe0M
 VinnHKxSDxwLnWrWnDGJOn1pxNp6VHSvzYOPfpFqQVY9Mb0i/KPFP8+VZRwWlntz496gri3fw
 EcsxpArJ5tPtsVsDkHUKHnNmrmGHP69Y1yH8VkcW8RzfoT9wsXOoOsW73YWH2W+m6ENQSRWWf
 icwsPxZK5Pt2QT94wbZG+rMWPJXr5o5RV1T9kynStAnCji3erwBX6NxQl21hWrU2jLNobun4B
 fYrCWanNWTBVPj6VkKm1JFDUtLO/JRbaLaskAXlo15NGIEiC69ce3LDBN+eLDAazJumMjK4Hy
 ngPYKzLEGPFoNs/OoNUx0fvg==

Through a build failure of LVM2 on musl-libc 1.2.5 in the Buildroot
autobuild service[1], I noticed that musl-libc's Scrt1 for microblaze
produces a relocation targeting the .text section, which subsequently
leads to a crash at run-time because musl-libc does not support
textrels[2]. Buildroot uses the "-z text" linker option to catch
textrels early, on musl-libc.

The error can be reduced to the following test case:

  $ cat hello.c
  #include <stdio.h>
  int main(void) { puts("Hello world!"); return 0; }
  $ host/bin/microblaze-buildroot-linux-musl-gcc hello.c -z text -pie -fPI=
C
  microblaze-buildroot-linux-musl/bin/ld: microblaze-buildroot-linux-musl/=
sysroot/lib/Scrt1.o:
    warning: relocation against `_start_c' in read-only section `.text'
  microblaze-buildroot-linux-musl/bin/ld: read-only segment has dynamic re=
locations
  collect2: error: ld returned 1 exit status

LVM2 uses -pie only after the AC_TRY_CCFLAG macro has determined that it
can be used. This is where the problem begins: AC_TRY_CCFLAG only tries
compiling, it does not try linking the resulting object file.

To catch problems like this, this patch changes AC_TRY_CCFLAG to link in
addition to compiling. By detecting correctly that -pie does not work on
musl-libc/microblaze with -ztext, the build failure in Buildroot is fixed.

[1]: http://autobuild.buildroot.net/results/dc4/dc4fc33eaeafe5d6707d26a373=
560402533954f6/build-end.log
[2]: https://www.openwall.com/lists/musl/2020/09/25/4

Signed-off-by: J. Neusch=C3=A4fer <j.neuschaefer@gmx.net>
=2D--
Hi, I'm cross-posting this to the LVM2, Buildroot, and musl mailing
lists to get potential feedback early on.
=2D--
 acinclude.m4 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/acinclude.m4 b/acinclude.m4
index 47fdd59c3..9b1d3a605 100644
=2D-- a/acinclude.m4
+++ b/acinclude.m4
@@ -25,7 +25,7 @@ AC_DEFUN([AC_TRY_CCFLAG],
     ac_save_CFLAGS=3D$CFLAGS
     CFLAGS=3D$1
     AC_CACHE_CHECK([whether $CC accepts $1 flag], [ac_cv_flag_$2],
-	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM()],
+	[AC_LINK_IFELSE([AC_LANG_PROGRAM()],
 			   [AS_VAR_SET([ac_cv_flag_$2], [yes])],
 			   [AS_VAR_SET([ac_cv_flag_$2], [no])])])
     CFLAGS=3D$ac_save_CFLAGS

=2D--
base-commit: 90a845a7087478a7cdc7a60d89d2e7ee1366160e
change-id: 20240811-microblaze-8ff8a6217471

Best regards,
=2D-
J. Neusch=C3=A4fer <j.neuschaefer@gmx.net>

