<!-- 
/******************************************************
* <h1>Gobierno del Estado de Nuevo Le�n</h1>
* <h2>Sistema de Gesti�n de Obra P�blica</h2>
*
* @author Neftal� L�pez E.
* @version 1.0
* @since 2019
* Fecha de Creaci�n: 11 mar 2019
* Descripcion: Include para el Breadcrumb
* Ultimo Cambio:
* Fecha del Ultimo Cambio:
********************************************************/
 -->
<%
String pageName=request.getParameter("pageName");
String path=request.getParameter("path");

%>
                <div class="page-title-breadcrumb" id="title-breadcrumb-option-demo">
                    <ol class="breadcrumb page-breadcrumb">
                        <li><i class="fa fa-home"></i>&nbsp;<a href="/index">Inicio</a>&nbsp;&nbsp;<i class="fa fa-angle-right"></i>&nbsp;&nbsp;</li>
                        <li class="hidden"><a href="#"><b><%=pageName%></b></a>
                        &nbsp;&nbsp;</li>
                    </ol>
                    <!-- 
                    <div class="clearfix"></div>
                     -->
                </div>
