<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="eloLogin.aspx.cs" Inherits="eloWebApp.eloLogin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
        <script type="text/javascript" src="js/jquery.min.js"></script>
    <script src="js/sha256.min.js"></script>
    <script src="js/sha256.js"></script>
    <script src="js/base64.js"></script>
    <script src="js/bcrypt.min.js"></script>
    <script src="js/bcrypt.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#btn').click(function () {
                debugger
           
            var uname = document.getElementById('txtUserName');
            var pwd = document.getElementById('txtPwd');

            var t = bcryptUserPassword(uname.value, pwd.value);
             alert('bcryptUserPassword : ' + t);
            
            // Create Login Salt
            CreateLoginSalt(uname.value,t);
           
            
            
            });
        });

        function sha256AsBase64(data) {
           
            var hash = sha256.create();
            hash.update(data).digest();
            var bcrypt = dcodeIO.bcrypt;
            var enc = bcrypt.encodeBase64(hash);
            return enc;
            //return sha256.create().update(data).digest();
        }
        function bcryptSaltFromUsername(username) {
            var hash = sha256.create().update(username).digest();
            var bcrypt = dcodeIO.bcrypt;
            //alert('userSalt : ' + '$2a$12$' + bcrypt.encodeBase64(hash, 16)); 
            return '$2a$12$' + bcrypt.encodeBase64(hash, 16);
        }
        function bcryptUserPassword(username, password) {
            var userSalt = bcryptSaltFromUsername(username);
            var q = sha256AsBase64(password);
            var bcrypt = dcodeIO.bcrypt;
            var d = bcrypt.hashSync(q, userSalt);
            return d;
        }

        function CreateLoginSalt(username,t)
        {        
            debugger
            var qlCLS = '{ "query":"mutation {createLoginSalt(input:{clientMutationId: \\"999111\\", username: \\"' + username + '\\"}) {clientMutationId, username, salt, expiry}}" }'
           
            $.ajax({
                type : 'POST',
                url: 'https://hml-api.elo.com.br/graphql-private',
                contentType: 'application/json;charset=utf-8',
                headers: {
                    client_id: 'e5f1a7ee-2f69-3226-bb82-5859fb6639d9',
                    Authorization: 'Basic ZTVmMWE3ZWUtMmY2OS0zMjI2LWJiODItNTg1OWZiNjYzOWQ5OmM5NzZhMzNiLTQwYjctM2Y2OS1iNWQ3LWJjMmJmMTZiNTIwZQ=='
                },
                data: qlCLS,
                dataType: 'json',
                success: function (data)
                {
                    debugger
                    var bcryptPassword = t;
                    var bcrypt = dcodeIO.bcrypt;
                    var challenge = bcrypt.hashSync(bcryptPassword, data.data.createLoginSalt.salt);

                    alert('qlCLS : ' + qlCLS);
                    alert('salt : ' + data.data.createLoginSalt.salt);
                    alert('challenge : ' + challenge);
                    // Create Login API
                    Login(username, challenge);
                   


                }
           });                
        }

        function Login(username, bchallenge) {
            debugger
            
            var qlLogin = '{"query":"mutation {login (input:{clientMutationId: \\"999112\\",username: \\"' + username + '\\",challenge: \\"' + bchallenge + '\\" } ) { clientMutationId     accessToken   } }" }'

           // alert('Login : ' + qlLogin);
            $.ajax({
                type: 'POST',
                url: 'https://hml-api.elo.com.br/graphql-private',
                contentType: 'application/json;charset=utf-8',
                headers: {
                    client_id: 'e5f1a7ee-2f69-3226-bb82-5859fb6639d9',
                    Authorization: 'Basic ZTVmMWE3ZWUtMmY2OS0zMjI2LWJiODItNTg1OWZiNjYzOWQ5OmM5NzZhMzNiLTQwYjctM2Y2OS1iNWQ3LWJjMmJmMTZiNTIwZQ=='
                },
                data: qlLogin,
                dataType: 'json',
                success: function (data) {
                    debugger
                    if (data.data != null) {
                        alert('AccessToken : ' + data.data.login.accessToken);
                    }
                    else
                    {
                        var d = JSON.parse(data.errors[0].message);
                        alert('Code : ' + d[0].code + '\n description : ' + d[0].description);
                    }
                }
            });
        }



        
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table>
                <tr>
                    <td colspan="2"><asp:Label ID="lblMessage" runat="server" Text="" ></asp:Label></td>
                </tr>

                <tr>
                    <td>User Name  : </td>  <td><asp:TextBox ID="txtUserName" runat="server"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Password  : </td>  <td><asp:TextBox ID="txtPwd" runat="server" TextMode="Password"></asp:TextBox></td>
                </tr>

                <tr>
                    <td></td>  <td><input id="btn" type="button" value="Login" /> </td>
                </tr>
                
            </table>

        </div>
        <div>
            <%--<input id="hidCeateLoginSalt" type="hidden" />--%>
            <input id="hidAccessToken" type="hidden" />
        </div>

    </form>
</body>
</html>
