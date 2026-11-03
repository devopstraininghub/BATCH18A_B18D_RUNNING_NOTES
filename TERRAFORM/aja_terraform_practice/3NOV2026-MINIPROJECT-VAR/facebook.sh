#!/bin/bash

yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
<title>Sample Facebook App</title>
<style>
  body {
    margin: 0;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    background: radial-gradient(circle at center, #1b2a6b, #0a0f2c);
    font-family: Arial, sans-serif;
  }
  .wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
    z-index: 1;
  }
  .logo {
    width: 120px;
    height: 120px;
    border-radius: 26px;
    background: #1877f2;
    color: #fff;
    font: bold 110px/150px Arial, sans-serif;
    text-align: center;
    overflow: hidden;
    box-shadow: 0 0 30px 6px rgba(24, 119, 242, 0.7), 0 0 60px 12px rgba(255, 215, 0, 0.35);
    animation: glow 2.5s ease-in-out infinite alternate;
  }
  @keyframes glow {
    from { box-shadow: 0 0 20px 4px rgba(24, 119, 242, 0.6), 0 0 40px 8px rgba(255, 215, 0, 0.2); }
    to   { box-shadow: 0 0 40px 10px rgba(24, 119, 242, 0.9), 0 0 80px 18px rgba(255, 215, 0, 0.5); }
  }
  h1 {
    margin: 0;
    font-size: 3em;
    text-align: center;
    background: linear-gradient(90deg, #ffd700, #fff, #ff69b4, #00e5ff, #ffd700);
    background-size: 300% 100%;
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
    animation: shimmer 3s linear infinite;
    text-shadow: 0 0 20px rgba(255, 215, 0, 0.4);
  }
  @keyframes shimmer {
    from { background-position: 0% 50%; }
    to   { background-position: 300% 50%; }
  }
  .sparkle {
    position: absolute;
    border-radius: 50%;
    background: #fff;
    box-shadow: 0 0 8px 2px gold;
    animation: twinkle 2s ease-in-out infinite;
    opacity: 0;
  }
  @keyframes twinkle {
    0%, 100% { opacity: 0; transform: scale(0.2); }
    50%      { opacity: 1; transform: scale(1.2); }
  }
</style>
</head>
<body>
<div class="wrap">
  <div class="logo">f</div>
  <h1>&#10024; THIS IS SAMPLE MC FACEBOOK APP PAGE &#10024;</h1>
</div>
<script>
  var colors = ['#ffd700', '#ffffff', '#ff69b4', '#00e5ff'];
  for (var i = 0; i < 80; i++) {
    var s = document.createElement('div');
    var size = 3 + Math.random() * 6;
    s.className = 'sparkle';
    s.style.width = s.style.height = size + 'px';
    s.style.left = Math.random() * 100 + 'vw';
    s.style.top = Math.random() * 100 + 'vh';
    s.style.background = colors[Math.floor(Math.random() * colors.length)];
    s.style.animationDelay = Math.random() * 2 + 's';
    s.style.animationDuration = 1 + Math.random() * 2 + 's';
    document.body.appendChild(s);
  }
</script>
</body>
</html>
EOF
