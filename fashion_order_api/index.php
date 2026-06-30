<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Fashion Order API</title>
<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Segoe UI,sans-serif;
}
body{
    min-height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
    background:linear-gradient(
        135deg,
        #CDB4DB,
        #BDE0FE,
        #D8F3DC
    );
}
.card{
    width:420px;
    background:white;
    border-radius:28px;
    padding:35px;
    box-shadow:0 20px 45px rgba(0,0,0,.12);
    text-align:center;
}
.logo{
    width:90px;
    height:90px;
    margin:auto;
    border-radius:50%;
    display:flex;
    justify-content:center;
    align-items:center;
    font-size:42px;
    background:#CDB4DB;
    color:white;

}
h1{

    margin-top:20px;
    font-size:32px;
    color:#333;

}
.version{
    color:#777;
    margin-top:6px;
}
.status{
    margin:30px 0;
    background:#D8F3DC;
    color:#198754;
    border-radius:16px;
    padding:15px;
    font-weight:bold;
    font-size:18px;
}
.info{
    text-align:left;
    margin-top:25px;
}
.item{
    display:flex;
    justify-content:space-between;
    padding:14px 0;
    border-bottom:1px solid #eee;
}
.item:last-child{
    border:none;
}
.footer{
    margin-top:28px;
    color:#999;
    font-size:13px;
}
.btn{
    display:inline-block;
    margin-top:25px;
    text-decoration:none;
    background:#CDB4DB;
    color:white;
    padding:13px 28px;
    border-radius:14px;
    transition:.3s;
}
.btn:hover{
    background:#B38CCB;
}

</style>
</head>
<body>
<div class="card">
<div class="logo">
👗
</div>

<h1>Fashion Order</h1>
<div class="version">
API Server v1.0
</div>

<div class="status">
🟢 Server Online
</div>

<div class="info">

<div class="item">
<span>PHP</span>
<span><?php echo phpversion(); ?></span>
</div>

<div class="item">
<span>Server Time</span>
<span><?php echo date("d M Y H:i"); ?></span>
</div>

<div class="item">
<span>Status</span>
<span>Connected</span>
</div>

<div class="item">
<span>Database</span>
<span>MySQL</span>
</div>

</div>

<a class="btn" href="dashboard.php">
Test API
</a>

<div class="footer">

Fashion Order Management System<br>
© <?php echo date("Y"); ?>
</div>
</div>
</body>
</html>