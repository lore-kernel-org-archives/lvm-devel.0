Received: from mail-ed1-f47.google.com (mail-ed1-f47.google.com [209.85.208.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEFD823504B
	for <lvm-devel@lists.linux.dev>; Fri, 24 Oct 2025 16:31:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761323514; cv=none; b=eaZQKE6p2aSevQrCm0AeXMSnSq/aXyxtrMX3oc/Qzeah9RpPRBtUlkkAMpuvet6GW/btbzvJolSzaaA2ap+X3f6bT1ZYVlYgmfSBx/rhDzU8AFKfMfrKkTjEUd93rmLIX3QRbsu36a8hiUynZM1ds52E67uqQlw1uVt9yYmWQwY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761323514; c=relaxed/simple;
	bh=2sni659oKETAt3mg4JWKS26aiVXJeHNTGhbFaOETvpg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YsL/67CnWLZ04ik8JbSXV5UeRTmWgVPNHZTa6npkJODUMzNUFZxrmdrhCnKFxprvKPYCFMUnNUAsH10u1/QrafyPYWjooEslwxEPZW659K7+FzTlKixRj5Osl+ASuMlQr7tHSMIFRBWIRxCtPe6Lub9SbpaoqvsTN9v6rnDBN30=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HdFczxX5; arc=none smtp.client-ip=209.85.208.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HdFczxX5"
Received: by mail-ed1-f47.google.com with SMTP id 4fb4d7f45d1cf-63c45c11be7so4053584a12.3
        for <lvm-devel@lists.linux.dev>; Fri, 24 Oct 2025 09:31:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1761323510; x=1761928310; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=OU6+xLScjAoCvkgYL37muGkf8RRryUsuClOGQPNvZ0U=;
        b=HdFczxX5tZoWsHoPJ/RDA6Uv4d94HZmuli9YrhHhymLZlm2MIlruQ8dghPot4o7ajm
         /WsEbjTL8J8HmcRSw5BCzd0f/LQfB4SdhI53t2FMlL9lPa9trP3sZLtPCINY/svF5Oav
         Ex9MXs+ry7yP1NWiq8/estOvbldgYj8Qhb7om67L+toCCkUByqU8nTwGUNbXIrEaoHKy
         JXnhY9yrRf6KKydxe/DiQWsskDjOIj5blRS/7MkF1MqJ/p7ulYRSnAwf6FaODHMRTeC4
         nIaeDQiFGjDps1ZSRabYM7j1+bLsNOzJ/1lVB0MInE5JZQrs3gYGLBr/KuagscQYatCQ
         upng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1761323510; x=1761928310;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=OU6+xLScjAoCvkgYL37muGkf8RRryUsuClOGQPNvZ0U=;
        b=GOq57/15cWEn8/PwpSxdl47eBw2NSJlYcaDhGu4yyK1yUcpo4u6i6OGWQR37qFfsmc
         +WHPW39dwbT1k+Tn8PpYWg5uGy8PJbKOLwkZ9KAOnlUZUhMUr9xzHZI9lLwy729f1wwe
         w8yy+abWP41dihH2CbHJlN1WeYAiV4qrRxNR7DZTDCUnncs8H9akYXKbEL8sIGgAgSdD
         pkryzqiYuBXikDhb6SnlqRC/mJykMdWXPYkhNfshTWeJeWc7J4r8m7/CLwJ8pY3uw7bz
         SN0za9f8P1bB4E2zkL7tGyAnub7qhu4BoA0xKsj3mDUKnrk8s91eBaDgGrNC0OGlrl3R
         J8qQ==
X-Forwarded-Encrypted: i=1; AJvYcCVxNQcr/l/J2tCWaYJeXpg6QsKXbPHPd+w92jpsJsFEYrHQtb8J2kFT7gjEDN789rkKgb3BQKN00yk=@lists.linux.dev
X-Gm-Message-State: AOJu0YzSwZDes2+DMrKQqUS1obLhAQJtxSQDlZRq7M2f4NOoydS6vwdV
	Ms1iQfCT5HmfwRrTfdKH6muuFpNA+VO8zBx+ZESmjrfURzZeE+On5sNP
X-Gm-Gg: ASbGncuepkHcndnjYafCvWtQ3rDsrweTTQVLazeeRHEvZRvEuoakbzyWURRkAkZAp7+
	Zg8AboB2O/5e6Jpn5Ab7NMDYrXFbqtBT5OU/TrIqrHZ4fhOn1O6fc6XTm2s/ptlYtFZ2xOOw4Wq
	DifRvPrf0kE8Qo5yFsKy3XZP5VEtYrxuAFAR5C5QQg5u/2X7P/LFg+l02ZFw4P9I8HOs5deeNk5
	/pNQr8QB6KvJMbmwLNlx2ElzWReFDVRfBPa1JKesJfEwPwgAG9ySgJDt0+3nyzeExvWs+zO9YO8
	W1rhVB5VbzLla+6y4hzjm//Rqi4bMnO4B+ZNS5etjmwcDFn/607XwgpJGmAKI1qbrydzrqPCB4i
	mXXFZoo8/5fgmvbEuJ4mIFph5pbwtoxiNiuI7M+jfkKsBMno6RQPpiuAA+QnnMESYiWjiPH1Erz
	LS
X-Google-Smtp-Source: AGHT+IGJrzUB5n97Ss2T/JTlLzP7kGDtRqESJivToHOWW6+qmykXupmsLuZ+wNfM3MQ1VRw6GaGwKg==
X-Received: by 2002:a05:6402:42ca:b0:63b:fbd9:3d9c with SMTP id 4fb4d7f45d1cf-63e6002459emr2596805a12.15.1761323509904;
        Fri, 24 Oct 2025 09:31:49 -0700 (PDT)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id 4fb4d7f45d1cf-63e3f316b64sm4717822a12.22.2025.10.24.09.31.47
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 24 Oct 2025 09:31:49 -0700 (PDT)
From: Askar Safin <safinaskar@gmail.com>
To: gmazyland@gmail.com
Cc: Dell.Client.Kernel@dell.com,
	brauner@kernel.org,
	dm-devel@lists.linux.dev,
	ebiggers@kernel.org,
	kix@kix.es,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	mzxreary@0pointer.de,
	nphamcs@gmail.com,
	pavel@ucw.cz,
	rafael@kernel.org,
	ryncsn@gmail.com,
	safinaskar@gmail.com,
	torvalds@linux-foundation.org
Subject: Re: dm bug: hibernate to swap located on dm-integrity doesn't work (how to get data redundancy for swap?)
Date: Fri, 24 Oct 2025 19:31:42 +0300
Message-ID: <20251024163142.376903-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <a48a37e3-2c22-44fb-97a4-0e57dc20421a@gmail.com>
References: <a48a37e3-2c22-44fb-97a4-0e57dc20421a@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Milan Broz <gmazyland@gmail.com>:
> Hi,

I just wrote script for reproduction of this bug in Qemu:
https://zerobin.net/?4e742925aedbecc6#BX3Tulvp7E3gKhopFKrx/2ZdOelMyYk1qOyitcOr1h8=

Just run it, and you will reproduce this bug, too.

Also, I just reproduced it on current master (43e9ad0c55a3).

Here is output of this script on master:
https://zerobin.net/?68ef6601ab203a11#7zBZ44AaVKmvRq161MJaOXIXY/5Hiv+hRUxWoqyZ7uE=

As you can see, hibernate succeeds, but resume fails so:

+ blkid --match-tag TYPE --output value /dev/mapper/early-swap
+ TYPE=swap
+ echo 'Type: swap'
Type: swap
+ echo /dev/mapper/early-swap
[    0.446545] PM: Image not found (code -22)

Also, I just noticed that the bug sometimes reproduces, and sometimes not.
Still it reproduces more than 50% of time.

Also, you will find backtrace in logs above. Disregard it. I think this
is just some master bug, which is unrelated to our dm-integrity bug.

I will answer to rest of your letter later.

Also, I saw patch, I will test it later.

-- 
Askar Safin
