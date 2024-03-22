Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com [209.85.208.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 75FC9634F9
	for <lvm-devel@lists.linux.dev>; Fri, 22 Mar 2024 18:18:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711131520; cv=none; b=Y3aHp6hlLsCR86qPW74RU7a+uYXPQWEO7cidiLwyA7Mc1bnQ5mzNoW1GDbsGz7/GGUrFnSq/SjuTRVbxrERYzt0D96MAlctVpOYz0Nq+XsDKy5ncA48brTAo1dNYcPVG0cukNH9CQ5zavssfgmwcfJHXoFqUo8kD62G9/ii6e9A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711131520; c=relaxed/simple;
	bh=y1g+QU5S92TtQUQZL0jQkrfg/yfjljdkyePCW8GS2Xw=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=isqi8Wi8CScaVCfoEjnorWPYrcIvUamLrMKD1XzKHy4+36KuvKx1zCpMMA60jW9N9YkmcQky5wq51hLh16x/YPFP7gt6afMiGcYupTifVbDDWoegUsQVtRrfqfWlHHhspFc0NYk1j6nrLm0d/ACsRz+Nu7Vd0VvUTeRQ1g6xtxo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=W9w5qXkh; arc=none smtp.client-ip=209.85.208.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W9w5qXkh"
Received: by mail-lj1-f174.google.com with SMTP id 38308e7fff4ca-2d21cdbc85bso33831261fa.2
        for <lvm-devel@lists.linux.dev>; Fri, 22 Mar 2024 11:18:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1711131516; x=1711736316; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=y1g+QU5S92TtQUQZL0jQkrfg/yfjljdkyePCW8GS2Xw=;
        b=W9w5qXkheh9aZOkPMBq1pIBYIuoBJD21+R9x3xMenNGiCHnSlkoHEEIVYiWk4LaJeU
         DGP0udmlN/BLFTUinf7/G8RqL0h4YkoGHiNS0BMmXQjNhqef4HTMVdEudbNSmovfeusD
         Kjj1xxi0QRPHbJkNHmlEEwcqnzKEIXfmpicusTuyVtccXEaAiMydn80ZlLH+Cb9AajUH
         hH/B0JpoXn151Zs1yV0RBEZOaMXwPiSbJnQIonHucLDY5I7vi3gPJ6ZQoiT5hcF7bu8B
         HHpl+kfaiN0H4BSJAb5dKJ2mNnASRnJKGNj9ijpc4/BZBIACzFzbN0/B/Ohov6/fjeMP
         uZJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1711131516; x=1711736316;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=y1g+QU5S92TtQUQZL0jQkrfg/yfjljdkyePCW8GS2Xw=;
        b=QeBD2P+0mceVnGVmddhrR/xNIpT9n2Txd3AwWoU3bCx4DaC1R160Idd4+jlRouMUO6
         wdsppuqFfeBchBfnbJocK7yC90ZXPeqMfWYZjtQyplx5oMV3emRp1Di3QdxxjUAKr7HF
         LiNN6jvTNcyBq91Jxhmt6Qjv29R3mMVt7enzcKKdmQX9hsv+ujdYj9+ce1OSBanglkg6
         333cFSbcyVJ3BPluCBkju2N/Xgntf2w44oe7lqX9nqqo8KzZ/VB+KuveeGFe3FKkCJKK
         dRsYYNsBMcFgzcqzeVGwSlcZ9y77rM/a1w/SNdRkKIfMxPQctSojNkNcKB16sRClWpbI
         0piQ==
X-Gm-Message-State: AOJu0YxhjWc+zSsCwdqsD6kHspV09HQ+rSVkJswi775+DHM+dM8RQ0mu
	N1BVIxLfqBdGvuMPC9fMD8s90zDKB+h6eNPZdInzz2Q27Kd3n8+4F1nLCRbHTsUYwGv6zraJALQ
	Vy8RvwbcoYO4KKGS3cAFx2kSzaWo+NdPKZDQ=
X-Google-Smtp-Source: AGHT+IGjbItnx+LJn9HlXhv+ZcXmyGcs02JOLBzMzo4eRIdk/6ox+RglRZPfOgvR5+x7k+Gwh3DFA8Tn5Wky9v3GDYk=
X-Received: by 2002:a2e:700c:0:b0:2d3:ba98:473 with SMTP id
 l12-20020a2e700c000000b002d3ba980473mr230987ljc.19.1711131516154; Fri, 22 Mar
 2024 11:18:36 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Patrick Plenefisch <simonpatp@gmail.com>
Date: Fri, 22 Mar 2024 14:18:24 -0400
Message-ID: <CAOCpoWfYjOVNJNt+cnOVXDHiDq2wRogTqBijcUoa7chqOLRa5Q@mail.gmail.com>
Subject: udev rule bug: LUKS on LVM doesn't expose labels
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi,

I noticed that my LUKS-on-LVM setup wasn't generating
/dev/disk/by-label symlinks. After some poking around, I realized that
the udev rule doesn't include crypto devices:

udev/13-dm-disk.rules.in:40

ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*",
SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"

In contrast, the uuid rule does support crypto devices:

udev/13-dm-disk.rules.in:39

ENV{ID_FS_USAGE}=="filesystem|other|crypto",
ENV{ID_FS_UUID_ENC}=="?*",
SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"

Adding "|crypto" to the label rule and everything seems to work fine
on my end. Is there some other behavior I'm missing here, or is this a
bug in the udev rules?

Patrick
