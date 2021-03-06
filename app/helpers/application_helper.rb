# coding: utf-8
module ApplicationHelper

  #metodo para mostrar as ações para cada modelo dada a permissão
  def show_actions_by_permission(permission)
    container = %(<ul class='skills'>)
    actionz = permission.actions.split(';')
    actionz.each do |action|
      container << %(<li>#{action}</li>)
    end
    container << '</ul>'
    container.html_safe
  end

  #metodo para mostrar os sub_menus de cada permissão
  def show_sub_menus_by_permission(menu,role)
    container = %(<ul class='skills'>)
    sub_menus = menu.sub_menus.joins(:roles).where('role_id = ?',role.id)
    sub_menus.each do |sm|
      container << "<li>#{sm.name}</li>"
    end
    container << '</ul>'
    container.html_safe
  end

  def owner_has_logo(owner)
    container = %()
    unless owner.nil?
      container << "<h1>#{link_to image_tag(owner.image.url(:small)),admin_root_path,:title => 'Link para: página inicial do sistema - dashboard '}</h1>"
    else
      container << "<h1>#{link_to '#',admin_root_path,:title => 'Link para: página inicial do sistema - dashboard '}</h1>"
    end
    container.html_safe
  end

  #metodo para mostrar o 'onde estou? na area admin'
  #argumento 'menu_name' é o nome do menu que irá ser exibido
  #argumento 'rota' é a rota para onde o link será direcionado
  #argumento 'texto' é a descrição do link
  def onde_estou(menu_name,rota,texto)
    container = %()
    if menu_name
      container << "<div class=\"localization\">"
      container << "<h2><em>Onde estou?</em>#{menu_name}</h2>"

      unless rota.nil?
        container << "<em class='right'>ir para: #{link_to texto,rota}</em>"
      end

      container << "</div>"
      container << "<span class=\"separator\">&nbsp;</span>"
    end
    container.html_safe
  end

  #metodo para criação do menu principal
  #menus são gerados a partir do current_user (usuario atual logado) e seus menus permitidos
  def create_menu
    user = User.find(current_user.id)
    if user.role.value == 5
      menu = Menu.order("position ASC")
    else
      menu = Menu.actived?.joins(:roles).where("menus_roles.role_id = ?",user.role.id).order("menus.position ASC")
    end
    list_menu = %()
    list_menu << "<li>#{link_to('início',admin_root_path,:alt => 'página inicial',:title => 'clique para ir para dashboard')}</li>"

    menu.each do |m|
      if user.role.value == 5
        sub = m.sub_menus.actived?.order("sub_menus.position asc") #SubMenu.all(::conditions => ["menu_id = ? AND menus.situation = ?", m.id, true], :order => "sub_menus.position")
      else
        sub = m.sub_menus.actived?.joins(:roles).where("roles_sub_menus.role_id = ?",user.role.id).order("sub_menus.position asc")
      end


      list_menu << "<li>"
      list_menu << link_to(m.name,'javascript:void(0);')
      list_menu << "<ul>"
      sub.each do |s|
        if s.separator.eql?(true)
          list_menu << "<li class='separator'>"
        else
          list_menu << "<li>"
        end
        list_menu << link_to(s.name,s.url,:title => s.title)
        list_menu << "</li>"
      end
      list_menu << "</ul>"
      list_menu << "</li>"
    end
    list_menu.html_safe
  end

  #metodo para exibir dados do usuario atual logado no sistema e links de logout
  def show_user
    if user_signed_in?
      container = %()
      container << "<div id='navTop'>"
      container << "<div id='tools'>"
      if flash[:notice]
        container << "<div class='information'>"
        container << "<span id='notice'><span>&nbsp;</span><h1>#{flash[:notice]}</h1></span>"
        container << "</div>"
      end
      container << "<div class='logged'>"
      container << "<span>#{image_tag avatar_url(current_user)}</span>"
      container << "<div>"
      container << "<h2>#{current_user.name}</h2>"
      container << "</div>"
      container << "<ul>"
      container << "<li>#{link_to('sair do sistema',destroy_user_session_path,:method => :delete,:title => 'efetuar logout')}</li>"
      container << "<li>.</li>"
      container << "<li>"
      container << link_to('meus dados',"javascript:createSearchPopup('/admin/users/#{current_user.id}',740,500);",:title => 'ver meus dados')
      container << "</li>"
      container << "</ul>"
      container << "</div>"
      container << "</div>" #tools
      container << "<span class='clear'>&nbsp;</span>"
      container << "</div>" #navTop
    end
    container.html_safe
  end


  #metodo que exibe imagem de gravar to usuario logado no sistema
  def avatar_url(user)
      default_url = "#{root_url}images/user-img.gif"
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_url)}"
  end

  #metodo para criação de sub-menus em site
  #argumento 'lista' recebe a lista de submenus
  #argumento 'classe' recebe a classe CSS que vai servir para criar separador SE houver
  def show_submenus(lista,classe)
    tamanho = lista.size-1
    li = %()
    lista.each_with_index do |obj,index|
      if tamanho == index
        li << %(<li>#{link_to(obj.title,obj,:title => "#{obj.title}",:class => classe)}</li>)
      else
        li << %(<li>#{link_to(obj.title,obj,:title => "#{obj.title}")}</li>)
      end
    end
    li.html_safe
  end

  def situation_is_true(obj,model)
    coluna = %()
    if obj.situation == true
      coluna << link_to_remote(image_tag('/images/mostrativo/desactive.png', :alt => 'ação: desativar registro', :title => 'ação: desativar registro'),:url => {:controller => "admin/homes",:action => "enabled_disabled",:id => obj.id, :name => model})
    else
      coluna << link_to_remote(image_tag('/images/mostrativo/active.png', :alt => 'ação: ativar registro', :title => 'ação: ativar registro'),:url => {:controller => "admin/homes",:action => "enabled_disabled",:id => obj.id, :name => model})
    end
  end

  #metodo para criação de radio buttons de maneira identada entre pai e filho, de dois niveis
  #argumento 'obj' é o objeto a ser passado
  #argumento 'field'
  def h_radios(obj,field)
    html = %()
    obj.each do |o|
      html << "<tr>"
			html << "<td>"
      html << "<div class='field other'>"
      html << "<label>"
      #faz o checkbox
      html << radio_button_tag(field,o.id)
      #traz antecessores
      unless o.parent.nil?
        o.ancestors.reverse.each do |a|
          html << a.name+" > "
        end
      end
      html << o.name
      html << "</label>"
      html << "</div>"
			html << "</td>"
      html << "</tr>"
    end
    html.html_safe
  end

  #metodo para criação de radio buttons de maneira identada entre pai e filho, de dois niveis dentro de uma DIV box
  #argumento 'obj' é o objeto a ser passado
  #argumento 'field'
  def h_radios_with_box(obj,field)
    html = %()
    html << "<tr>"
    html << "<td>"
    html << "<div class='box'>"
    obj.each do |o|
      html << "<label>"
      #faz o checkbox
      html << radio_button_tag(field,o.id)
      #traz antecessores
      unless o.parent.nil?
        o.ancestors.reverse.each do |a|
          html << a.name+" > "
        end
      end
      html << o.name
      html << "</label><br/>"
    end
    html << "</div>"
    html << "</td>"
    html << "</tr>"

    html.html_safe
  end

  #metodo para exibir valor de moeda formatado
  def formated_value(valor)
    number_to_currency(valor,:unit => "R$",:separator => ",",:delimiter => ".")
  end

  #metodo para rendenizar erros de validação, recebe o objeto como argumento
  def error_message_for(resource)
    render "/admin/others/error_message",:target => resource
  end

  #metodo para exibição de imagem no forms de 'edit'
  #se houver imagem a mesma é gerada com um link para deletar o arquivo
  #argumento 'objeto' é o objeto a qual se deseja exibir a imagem
  def show_image(objeto)
    controller = objeto.class.to_s.downcase.pluralize
    container = %()
    if objeto.image?
      container << "<div class='field'>"
      container << "<span>"
      container << "<label for='img'>"
      container << image_tag(objeto.image.url(:small))
      container << "</label>"
      container << "</span>"
      container << "<span><label>"
      container << link_to('Excluir Imagem',"/admin/#{controller}/#{objeto.id}/delete_image")
      container << "</label></span>"
      container << "</div>"
    end
    container.html_safe
  end

  # ===== ===== ===== helpers de formulários - inicio ===== ===== ===== #

  #######################################

  # => METODOS DE FORMULÁRIO PARA INCLUSÃO/EDIÇÃO  - INICIO

  #######################################

  #metodo que cria um input text no formulário
  #argumento 'form' é o formulario que deve ser passado
  #argumento 'objeto' objeto para qual o form será criado
  #argumento 'campo' campo para qual o input será criado
  #argumento 'container_options = {}', hash que vai conter as opções do container onde está o input_text_for_form
  ###opções : :class -> define a classe para o container
  #ex : na chamada passar input_text_for_form(objeto,campo,{:chave => 'valor'}) pode ser recupeado no metodo com container_options[:chave]
  #argumento 'campo_options = {}', hash que vai conter opções do campo a ser inserido
  ###opções do 'campo_options' :
  ### :class => define a classe do input
  ### :information => define um information que será exibido abaixo do campo
  ### :error_message => define uma mensagem de error
  ### :label_for => define o label que será exibido para o campo
  ### :input_name => define name do input
  ### :input_type => define tipo do input => text/password/file
  #ex : na chamada passar input_text_for_form(objeto,campo,{},{:chave => 'valor'}) pode ser recupeado no metodo com campo_options[:chave]
  def input_text_for_form(form,objeto,campo,container_options = {},campo_options = {})
    #opções container
    container_class     = container_options[:class].nil? ? "field" : container_options[:class]
    #opções input
    input_class         = campo_options[:class].nil? ? "" : campo_options[:class]
    input_information   = campo_options[:information] unless campo_options[:information].blank?
    input_error_message = campo_options[:error_message] unless campo_options[:error_message].blank?
    input_label_for     = campo_options[:label_for].nil? ? "txt#{campo.to_s.camelize}" : campo_options[:label_for]
    input_name          = campo_options[:input_name].nil? ? "#{objeto.class.to_s.underscore.downcase}[#{campo}]" : campo_options[:input_name]
    input_type          = campo_options[:input_type].nil? ? "text" : campo_options[:input_type]

    container = %(<div class="#{container_class}">)
    container << "<span>"
    container << "<label for=\"#{input_label_for}\">"
    container << t("activerecord.attributes.#{objeto.class.to_s.underscore.downcase}.#{campo.to_s}")
    container << link_to("[?]",'javascript: void(0);',:class => "showHelp",:title => 'clique aqui para pedir ajudar sobre o campo') if input_information

    case input_type
      when 'text'
        container << form.text_field(campo,:name => input_name,:class => input_class)
      when 'file'
        container << form.file_field(campo,:name => input_name,:class => input_class)
      when 'password'
        container << form.password_field(campo,:name => input_name,:class => input_class)
      when 'checkbox'
        container << form.check_box(campo,{:name => input_name,:class => input_class})
      when 'radio'
        container << form.radio_button(campo,objeto.id,{:name => input_name,:class => input_class})
    end

    container << "</label>"
    container << "<span class='help'>#{link_to('x','javascript: void(0)',:title => 'clique para fechar a ajuda')} #{input_information}</span>" if input_information
    container << "<span class='message'>#{input_error_message}</span>" if input_error_message
    container << "</span>"
    container << "<div class='clear'>&nbsp;</div>"
    container << "</div>"
    container.html_safe
  end

  #metodo que cria input para create_container
  #argumento 'form' é o form que vai ser passado
  #argumento 'objeto' objeto para qual o form será criado
  #argumento 'campo' campo para qual o input será criado
  #argumento 'container_options = {}', hash que vai conter as opções do container onde está o input_text_for_form
  ###opções : :class -> define a classe para o container
  #ex : na chamada passar input_text_for_form(objeto,campo,{:chave => 'valor'}) pode ser recupeado no metodo com container_options[:chave]
  #argumento 'campo_options = {}', hash que vai conter opções do campo a ser inserido
  ###opções do 'campo_options' :
  ### :class => define a classe do input
  ### :information => define um information que será exibido abaixo do campo
  ### :error_message => define uma mensagem de error
  ### :label_for => define o label que será exibido para o campo
  ### :input_name => define name do input
  ### :input_type => define tipo do input => text/password/file
  #ex : na chamada passar input_text_for_form(objeto,campo,{},{:chave => 'valor'}) pode ser recupeado no metodo com campo_options[:chave]
  def input_text_for_block(form,objeto,campo,container_options = {},campo_options = {})
    #opções container
    container_class = container_options[:class].nil? ? "field" : container_options[:class]
    #opções input
    input_class         = campo_options[:class].nil? ? "" : campo_options[:class]
    input_information   = campo_options[:information] unless campo_options[:information].blank?
    input_error_message = campo_options[:error_message] unless campo_options[:error_message].blank?
    input_label_for     = campo_options[:label_for].nil? ? "txt#{campo.to_s.camelize}" : campo_options[:label_for]
    input_name          = campo_options[:input_name].nil? ? "#{objeto.class.to_s.underscore.downcase}[#{campo}]" : campo_options[:input_name]
    input_type          = campo_options[:input_type].nil? ? "text" : campo_options[:input_type]

    container = %()
    container << "<span>"
    container << "<label for=\"#{input_label_for}\">"
    container << t("activerecord.attributes.#{objeto.class.to_s.underscore.downcase}.#{campo.to_s}")
    container << link_to("[?]",'javascript: void(0);',:class => "showHelp",:title => 'clique aqui para pedir ajudar sobre o campo') if input_information

    case input_type
      when 'text'
        container << form.text_field(campo,:name => input_name,:class => input_class)
      when 'file'
        container << form.file_field(campo,:name => input_name,:class => input_class)
      when 'password'
        container << form.password_field(campo,:name => input_name,:class => input_class)
      when 'checkbox'
        container << form.check_box(campo,{:name => input_name,:class => input_class})
      when 'radio'
        container << form.radio_button(campo,objeto.id,{:name => input_name,:class => input_class})
    end

    container << "</label>"
    container << "<span class='help'>#{link_to('x','javascript: void(0)',:title => 'clique para fechar a ajuda')} #{input_information}</span>" if input_information
    container << "<span class='message'>#{input_error_message}</span>" if input_error_message
    container << "</span>"

    container.html_safe
  end

  #metodo que cria um container para agrupar grupos de 2/3/4 inputs
  #argumento 'classe' é a classe do CSS que define 2,3,4 por gruo
  #argumento '&block' cria o bloco de codigo com 2/3/4 input_for_blocks ou combo_box_for_block
  def create_container(classe,&block)
    container = %()
    container << %(<div class='#{classe}'>)
    container << capture(&block)
    container << "</div>"
    container << "<div class='clear'>&nbsp;</div>"
    container.html_safe
  end

  #metodo que cria o campo com verificação de força de senha
  def create_password_strength
    container = %()
    container << "<span>"
    container << "<label>Força da Senha"
    container << "<span class='password-strength'>Indefinido</span>"
    container << "</label>"
    container << "</span>"
    container.html_safe
  end

  #metodo que criar a estrutura de campos senhas
  #argumento 'objeto' objeto para qual o form será criado
  #argumento 'campo' campo para qual o input será criado
  #argumento 'container_options = {}', hash que vai conter as opções do container onde está o input_text_for_form
  ###opções : :class -> define a classe para o container
  #ex : na chamada passar create_password_container(objeto,campo,{:chave => 'valor'}) pode ser recupeado no metodo com container_options[:chave]
  #argumento 'campo_options = {}', hash que vai conter opções do campo a ser inserido
  ###opções do 'campo_options' :
  ### :class => define a classe do input
  ### :information => define um information que será exibido abaixo do campo
  ### :error_message => define uma mensagem de error
  ### :label_for => define o label que será exibido para o campo
  ### :input_name => define name do input
  ### :input_type => define tipo do input => text/password/file
  #ex : na chamada passar create_password_container(objeto,campo,{},{:chave => 'valor'}) pode ser recupeado no metodo com campo_options[:chave]
  def create_password_container(form,objeto,campo,container_options = {},campo_options = {})
    container = %()
    container << "<div class='field triple'>"
      container << input_text_for_block(form,objeto,campo,container_options,campo_options)
      container << "<span>"
      container << "<label for=\"txtConfirmPass\">Confirmar Senha"
      container << "<input type=\"password\" name=\"txtConfirmPass\" class=\"confirm\" />"
      container << "</label>"
      container << "<span class=\"message\">A senha de confirmação é diferente</span>"
      container << "</span>"
      container << create_password_strength
      container << "<div class=\"clear\">&nbsp;</div>"
    container << "</div>"
    container.html_safe
  end

  #metodo que cria um campo input com campo search para busca
  #necessario criar o metodo 'search' dentro do controller do objeto
  #necessario criar a rota -> para resouces com chamada via GET para o metodo criado no controller
  #esse metodo precisar rendernizar layout 'search'
  def input_text_with_search(objeto,campo,container_options = {},campo_options = {})
    route_for_seach = objeto.class.to_s.underscore.downcase.pluralize
    #opções de container_options
    container_class = container_options[:class].nil? ? "field" : container_options[:class]
    #opções de campo_options
    input_class         = campo_options[:class].nil? ? "" : campo_options[:class]
    input_information   = campo_options[:information] unless campo_options[:information].blank?
    input_error_message = campo_options[:error_message] unless campo_options[:error_message].blank?
    input_label_for     = campo_options[:label_for].nil? ? "txt#{campo.to_s.camelize}" : campo_options[:label_for]
    input_name          = campo_options[:input_name].nil? ? "#{objeto.class.to_s.underscore.downcase}[#{campo}_name]" : campo_options[:input_name]
    input_type          = campo_options[:input_type].nil? ? "text" : campo_options[:input_type]

    input_hidden_name = "#{objeto.class.to_s.underscore.downcase}[#{campo}_id]"

    container = %()
    container << "<div class='#{container_class}'>"
    container << "<span class='searchBtn'>"
    container << "<input type='hidden' name='#{input_hidden_name}' id='txtId'/>"
    container << "<label for='#{input_label_for}'>"
    container << t("activerecord.attributes.#{objeto.class.to_s.underscore.downcase}.#{campo.to_s}")
    container << "<input type='text' name='#{input_name}' id='txtName' disabled='disabled' />"
    container << link_to("...","javascript:createSearchPopup(\"/admin/#{route_for_seach}/search\", 760, 540)",:class => "filter",:title => "clique para abrir o campo de busca")
    container << "</label>"
    container << "</span>"
    container << "<div class=\"clear\">&nbsp;</div></div>"
    container.html_safe
  end


  #metodo que gera a listagem em tabela do popup search
  #argumento 'lista' é a lista de objetos
  #argumento 'table_options' é um hash que poderá conter um HASH de outras colunas para serem exibidas
  #arguemtno 'modelo' é o modelo que vai ser buscado
  def list_table_for_search(lista)
    container = %(<table name="list" summary="" cellpadding="0" cellspacing="0" width="740">)
        container << %(<thead><tr>)
        container << %(<td width='50'>ID</td>)
        container << %(<td width='650'>Nome</td>)
        container << %(</tr></thead>)
        container << %(<tbody>)
          lista.each do |l|
            container << %(<tr>)
            container << %(<td>#{l.id}</td>)
            container << %(<td>)
            container << link_to('selecionar','javascript:void(0)',:onclick => "javascript:closeSearchPopup('txtName','#{l.name}','#{l.id}')",:class => 'select')
            container << %(<h3>#{l.name}</h3>)
            container << %(</td>)
            container << %(</tr>)
          end
        container << %(</tbody>)
        container << %(</table>)
        container << "#{will_paginate(lista)}"
    container.html_safe
  end

  #metodo que cria o cabeçalho de busca na tela de search
  #argumento 'modelo' é o nome do modelo que vai ser buscado
  #argumento 'total_registros' é gerado pelo SIZE no controler, e mostra a quantidade total de registros
  def search_form_on_search(total_registros)
    container = %(<div class='box search'>)
    container << %(<form action='' method=''>)
    container << %(<label for='txtSearch'>Busca)
    container << %(<span><input type='text' name='search' />)
    container << %(</span>)
    container << %(</label>)
    container << %(<input type='submit' name='btnSearch' class='btn' value='buscar' />)
    container << %(</form>)
    container << select_per_page
    container << "<p><em>#{total_registros}</em> registro(s) encontrados"
    container << "<span class=\"clear\">&nbsp;</span>"
    container << "</div>"
    container.html_safe
  end

  #metodo que cria um combo box para formulários
  #argumento 'objeto' é o objeto que será gravado, exemplo tela de Novo Cliente objeto é @client
  #argumento 'campo' é o campo que vai ser gravado geralmente é salvo o id, ex : passado campo 'menu' é concatenado 'menu_id' para gravar
  #argumento 'lista' é a lista de objetos que serão exibidos no combo
  #argumento 'container_options = {}', hash que vai conter as opções do container onde está o input_text_for_form
  ###opções : :class -> define a classe para o container
  ###opções : :description -> é a descriçaõ do campo
  #ex : na chamada passar combo_box_for_form(objeto,campo,{:chave => 'valor'}) pode ser recupeado no metodo com container_options[:chave]
  #argumento 'campo_options = {}', hash que vai conter opções do campo a ser inserido
  ###opções do 'campo_options' :
  ### :input_name => define name do select de onde vai ser pego o valor e jogado para o banco
  #ex : na chamada passar combo_box_for_form(objeto,campo,{},{:chave => 'valor'}) pode ser recupeado no metodo com campo_options[:chave]
  def combo_box_for_form(objeto,campo,lista,container_options = {},campo_options = {})
    #opções de container
    container_class = container_options[:class].nil? ? "field" : container_options[:class]
    description     = container_options[:description].nil? ? "Selecione um #{campo.to_s.camelize}" : container_options[:description]
    #opcoes do select
    select_name = campo_options[:select_name].nil? ? "#{objeto.class.to_s.underscore.downcase}[#{campo}_id]" : campo_options[:select_name]

    #opcoes do campo
    option_value = campo_options[:option_value].nil? ? :id : campo_options[:option_value].to_sym
    option_text  = campo_options[:option_text].nil? ? :name : campo_options[:option_text].to_sym

    if option_value.eql?(:id)
      campo_to_save = "#{campo}_id"
    else
      campo_to_save = campo
    end

    container = %(<div class='#{container_class}'>)
    container << "<span><label for='options'>#{description}"
    container << collection_select(objeto.class.to_s.underscore.downcase,campo_to_save,lista,option_value,option_text,:prompt => 'Selecione...')
    container << "</select></label></span></div><div class='clear'>&nbsp;</div>"
    container.html_safe
  end

  #metodo que cria um combo box para formulários
  #argumento 'objeto' é o objeto que será gravado, exemplo tela de Novo Cliente objeto é @client
  #argumento 'campo' é o campo que vai ser gravado geralmente é salvo o id, ex : passado campo 'menu' é concatenado 'menu_id' para gravar
  #argumento 'lista' é a lista de objetos que serão exibidos no combo
  #argumento 'container_options = {}', hash que vai conter as opções do container onde está o input_text_for_form
  ###opções : :class -> define a classe para o container
  ###opções : :description -> é a descriçaõ do campo
  #ex : na chamada passar combo_box_for_form(objeto,campo,{:chave => 'valor'}) pode ser recupeado no metodo com container_options[:chave]
  #argumento 'campo_options = {}', hash que vai conter opções do campo a ser inserido
  ###opções do 'campo_options' :
  ### :input_name => define name do select de onde vai ser pego o valor e jogado para o banco
  #ex : na chamada passar combo_box_for_form(objeto,campo,{},{:chave => 'valor'}) pode ser recupeado no metodo com campo_options[:chave]
  def combo_box_for_block(objeto,campo,lista,container_options = {},campo_options = {})
    #opcoes do select
    select_name = campo_options[:select_name].nil? ? "#{objeto.class.to_s.underscore.downcase}[#{campo}_id]" : campo_options[:select_name]

    #opcoes do container
    description = container_options[:description].nil? ? "Selecione um #{campo.to_s.camelize}" : container_options[:description]

    #opcoes do campo
    option_value = campo_options[:option_value].nil? ? :id : campo_options[:option_value].to_sym
    option_text  = campo_options[:option_text].nil? ? :name : campo_options[:option_text].to_sym

    if option_value.eql?(:id)
      campo_to_save = "#{campo}_id"
    else
      campo_to_save = option_value
    end

    container = %()
    container << "<span><label for='options'>#{description}"
    container << collection_select(objeto.class.to_s.underscore.downcase,campo_to_save,lista,option_value,option_text,:prompt => 'Selecione...')
    container << "</label></span>"
    container.html_safe
  end


  #metodo que gera area com checkbox
  #argumento 'lista' é a lista de objetos que vai ser exibido para seleção
  #argumento 'objeto' é o modelo da tela atual ex : se está no cadastro de User o modelo_atual é User
  #argumento 'modelo_referenciado' é o modelo que se associa o modelo_atual ex : está em user é vai associar a vários Permission, o modelo referenciado é Permission
  #argumento é a 'associação' entre os objeto.modelo_referenciado ex : se é associação entre Post x Category -> associacao = @post.categories ou
  def check_box_for_form(lista,objeto,modelo_referenciado,associacao,container_options = {},campo_options = {})
    #container options
    legend          = container_options[:legend].nil? ? "Selecione suas opções" : container_options[:legend]
    container_class = container_options[:class].nil? ? "field" : container_options[:class]
    container_id    = container_options[:container_id].nil? ? "" : container_options[:container_id]
    #item options
    class_for_item  = campo_options[:class].nil? ? "item" : campo_options[:class]

    input_name = "#{objeto.class.to_s.underscore.downcase}[#{modelo_referenciado.to_s.underscore.downcase}_ids][]"

    container = %()
    container << "<div class='#{container_class}' id='#{container_id}'>"
    container << "<span>"
    container << "<fieldset>"
    container << "<legend>#{legend}</legend>"
    lista.each do |l|
        container << "<span class='#{class_for_item}'>"
        container << check_box_tag("#{input_name}",l.id,associacao.include?(l))
        container << l.name
        container << "</span>"
      end
    container << "</fieldset></span></div>"
    container.html_safe
  end

  #metodo que criar um radio button para formulário
  #argumento 'lista' é a lista de objetos a ser percorrida e exibida
  #argumento 'campo' é o campo que será gravado : ex se irá gravar Menu só passar :menu
  #argumento 'objeto' é o objeto atual que será gravado ex : se vai cadastrar novo menu objeto é @menu
  def radio_button_for_form(form,objeto,campo,lista,container_options = {},campo_options = {})
    #opções de container
    container_class = container_options[:class].nil? ? "field" : container_options[:class]
    legend = container_options[:legend].nil? ? "Selecione uma opção" : container_options[:legend]
    #opções de item
    input_class = campo_options[:class].nil? ? "item" : campo_options[:class]

    input_name = "#{objeto.class.to_s.underscore.downcase}[#{campo}_id]"

    container = %(<div class='#{container_class}'><span><fieldset>)
    container << %(<legend>#{legend}</legend>)
      lista.each do |l|
         container << %(<span class='#{input_class}'>)
         container << form.radio_button("#{campo}_id",l.id)
         container << l.name
         container << %(</span>)
      end
    container << %(</fieldset></span></div>)
    container.html_safe
    # =>
  end

  #metodo que cria um text area
  #opções de campo :
    ## rows -> define linhas
    ## cols -> define colunas
  def textarea_for_form(form,objeto,campo,container_options = {},campo_options = {})
    #opções de container
    container_class = container_options[:class].nil? ? "field" : container_options[:class]
    description     = container_options[:description].nil? ? "Descrição" : container_options[:description]
    #opções de campo
    rows = campo_options[:rows].nil? ? "7" : campo_options[:rows]
    cols = campo_options[:cols].nil? ? "85" : campo_options[:cols]

    input_name = "#{objeto.class.to_s.underscore.downcase}[#{campo}]"

    container = %()
    container << %(<div class='#{container_class}'><span>)
    container << %(<label for='txt'>#{description})
    container << form.text_area(campo,{:rows => rows,:cols => cols})
    #container << %(<textarea name='#{input_name}' rows='#{rows}' cols='#{cols}'></textarea>)
    container << %(</label></span></div>)
    container.html_safe
  end

  #cria botões de ação no fim da página
  def create_actions_buttons(label_button,container_options = {})
    container_class = container_options[:class].nil? ? "actions" : container_options[:class]

    container = %(<div class='#{container_class}'>)
		container	<< "<input type=\"submit\" value='#{label_button}' />"
		container	<< "<input type=\"reset\" value=\"limpar\" /></div>"
    container.html_safe
  end
  #######################################

  # => METODOS DE FORMULÁRIO PARA INCLUSÃO/EDIÇÃO  - FIM

  #######################################

  #######################################

  # => METODOS DE LISTAGEM  - INICIO

  #######################################

  #metodo para exibir a lista na página index
  #argumento 'modelo' é modelo que irá ser listado
  #argumento 'lista' é a lista de objetos a ser mostrada
  #argumento 'container_options' são HASH opções do container do elemento
  #argumento 'campo_options' são HASH opções do elemento
  ###opções do campo_options
  ### show_actions => true/false -> exibir links de ações para o item
  def list_model(modelo,lista,container_options = {},campo_options = {})
    #campo_options
    show_actions  = campo_options[:show_actions].nil? ? true : campo_options[:show_actions]
    show_edit     = campo_options[:show_edit].nil? ? true : campo_options[:show_edit]
    show_destroy  = campo_options[:show_destroy].nil? ? true : campo_options[:show_destroy]
    show_details  = campo_options[:show_details].nil? ? true : campo_options[:show_details]

    #container options
    show_mark_all           = container_options[:show_mark_all].nil? ? true : campo_options[:show_mark_all]
    show_em_massa           = container_options[:show_em_massa].nil? ? true : campo_options[:show_em_massa]
    show_order              = container_options[:show_order].nil? ? true : campo_options[:show_order]
    show_per_page           = container_options[:show_per_page].nil? ? true : campo_options[:show_per_page]
    #rotas editar/excluir/show
    route_for_model = modelo.to_s.underscore.downcase.pluralize
    base_route = "/admin/#{route_for_model}/"

    container = %()
    container << "<div class='box tools'>"
    container << "<span>"
    container << "<input type='checkbox' name='' value='' class='markAll' /><em>marcar todos</em>" if show_mark_all
    container << select_acoes_massa if show_em_massa
    container << "</span>"
    container << "<span>"
    container << select_order(modelo) if show_order
    container << "</span>"
    container << "<span class='ordem'>"
    container << select_ordem if show_order
    container << "</span>"
    container << "<span>"
    container << select_per_page if show_per_page
    container << "</span>"
    container << "</div>"
    container << hidden_field_tag("orderby",nil,:id => 'orderby')
    container << hidden_field_tag("ordem",nil,:id => 'ordem')
    container << hidden_field_tag("modelo",modelo,:id => "modelo")
    container << hidden_field_tag("ids[]")
    container << "<div class='box results' id='listagem'>"
    container << "<ul>"
      lista.each do |l|
        if l.respond_to? :situation
          if l.situation == true
            container << "<li class='ativado'>"
          else
            container << "<li class='desativado'>"
          end
        else
          container << "<li>"
        end


        container << "<input type='checkbox' name='cb_#{l.id}' value='#{l.id}' />"
        container << "<div class='info'>"
        #container << "<span>###</span>"
          if l.respond_to? :name
            container << "<h2>#{l.name}</h2>"
          elsif l.respond_to? :path
            container << "<h2>#{l.path}</h2>"
          elsif l.respond_to? :model_name
            container << "<h2>#{l.role.name} - #{l.model_name}</h2>"
          end
        #container << "<em class='address'></em>"
        #container << "<p></p>"
        container << "</div>" #class info

        if show_actions == true
          container << "<ul class='options'>"
          container << "<li>"
          container << link_to('editar',"#{base_route}#{l.id}/edit") if show_edit
          container << "</li>"
          container << "<li>"
          container << link_to('visualizar',"javascript:createSearchPopup('#{base_route}#{l.id}',740,500);",:title => "cliquei para ver todos os dados do item") if show_details
          container << "</li>"
          container << "<li>"

          if l.respond_to? :name
            container << link_to('excluir',"#{base_route}#{l.id}",:method => :delete,:confirm => "Uma vez excluido o registro não poderá ser recupeado!Tem certeza que deseja excluir o registro : #{l.name}") if show_destroy
          elsif l.respond_to? :path
            container << link_to('excluir',"#{base_route}#{l.id}",:method => :delete,:confirm => "Uma vez excluido o registro não poderá ser recupeado!Tem certeza que deseja excluir o registro : #{l.path}") if show_destroy
          elsif l.respond_to? :model_name
            container << link_to('excluir',"#{base_route}#{l.id}",:method => :delete,:confirm => "Uma vez excluido o registro não poderá ser recupeado!Tem certeza que deseja excluir o registro : #{l.model_name}") if show_destroy
          end
          #container << link_to('excluir',"#{base_route}#{l.id}",:method => :delete,:confirm => "Uma vez excluido o registro não poderá ser recupeado!Tem certeza que deseja excluir o registro : #{l.name}") if show_destroy
          #container << link_to('excluir','javascript:void(0)',:rel => l.id,:class => 'deletar')
          container << "</li>"

          if l.respond_to? :situation
            if l.situation == true
              container << "<li>"
              container << link_to('desativar',
                            {
                              :controller => "admin/home",
                              :action => "enabled_disabled",
                              :id => l.id,
                              :name => modelo.to_s
                            },
                              :alt => "ação : desativar",
                              :title => "ação desativar registro",
                              :class => "status",
                              :remote => true
                            )
              container << "</li>"
            else
              container << "<li>"
              container << link_to('ativar',
                            {
                              :controller => "admin/home",
                              :action => "enabled_disabled",
                              :id => l.id,
                              :name => modelo.to_s
                            },
                              :alt => "ação : ativar",
                              :title => "ação ativar registro",
                              :class => "status",
                              :remote => true
                            )
              container << "</li>"
            end
          end

          container << "</ul>"
        end

        container << "</li>"
      end
    container << "</ul>"
    container << "#{will_paginate(lista)}"
    container << "</div>" #box resultsativado
    container.html_safe
  end

   #metodo que vai criar o select box para exibir escolha de ordem e itens por página
  def select_order(modelo)
    not_columns = ["id", "created_at", "updated_at", "status","position","adm","encrypted_password","reset_password_token","failed_attempts", "unlock_token", "current_sign_in_ip", "last_sign_in_ip","current_sign_in_at", "reset_password_sent_at","image_file_size","image_content_type","image_file_name"]
    colunas = modelo.column_names - not_columns
    modelo  = modelo.to_s.underscore.downcase
    container = %()
    container << "<ul id='ordenar'><li>"
    container << link_to('ordenar dados','javascript:void(0);',:class => 'ordem',:title => 'clique para escolher quantos itens por página deseja exibir')
    container << "<ul>"

    colunas.each do |c|
      container << %(<li rel="#{c}">)
      container << link_to(t("activerecord.attributes.#{modelo}.#{c}"),'javascript:void(0);')
      container << %(</li>)
    end

    container << "</ul></li></ul>"
    container.html_safe
  end

  #metodo que cria o per_page
  def select_per_page(classe = 'perpage')
    container = %()
    container << "<ul class='#{classe}'>"
    container << "<li>#{link_to 'itens por página','javascript:void(0);',:title => 'selecione a quantidade de itens por página'}"
    container << "<ul>"
    container << "<li>#{link_to 'exibir 15 itens','javascript:void(0);',:title => 'exibir 15 itens',:rel => 15}</li>"
    container << "<li>#{link_to 'exibir 30 itens','javascript:void(0);',:title => 'exibir 30 itens',:rel => 30}</li>"
    container << "<li>#{link_to 'exibir 50 itens','javascript:void(0);',:title => 'exibir 50 itens',:rel => 50}</li>"
    container << "<li>#{link_to 'exibir 100 itens','javascript:void(0);',:title => 'exibir 100 itens',:rel => 100}</li>"
    container << "</ul></li></ul>"
    container.html_safe
  end

  #metodo que cria a ordenção ascendente ou descendente
  def select_ordem
    container = %()
    container << "<ul class='show'><li>#{link_to('ordenar','javascript:void(0);')}"
    container << "<ul>"
    container << "<li>#{link_to('A..Z','javascript:void(0);',:rel => 'ASC')}</li>"
    container << "<li>#{link_to('Z..A','javascript:void(0);',:rel => 'DESC')}</li>"
    container << "</ul></li></ul>"
    container.html_safe
  end

  #metodo que cria o select box para exibir as ações em massa
  def select_acoes_massa
    container = %()
    container << "<ul id='acoes_em_massa'>"
    container << "<li>"
    container << link_to("ações em massa",'javascript:void(0);',:title => "selecione uma ação em massa")
    container << "<ul>"
    container << "<li>#{link_to 'desativar/ativar','javascript:void(0);',:id => "enable_disable"}</li>"
    container << "<li>#{link_to 'apagar todos','javascript:void(0);',:id => "destroy_all"}</li>"
    container << "</ul>"
    container << "</li>"
    container << "</ul>"
    container.html_safe
  end

  #metodo que exibe os dados no show
  #argumento objeto é o objeto que irá ser exibido
  #argumento 'campo' é o campo do objeto a ser exibidos
  #arguemento 'campo_options' é um HASH de opções
  def show_field(objeto,campo,campo_options = {})
    field_name = campo_options[:field_name].nil? ? objeto.class.human_attribute_name(campo.to_s) : campo_options[:field_name]
    conteudo   = campo_options[:content] unless campo_options[:content].nil?
    content    = objeto.send(campo)

    container = %()
    if content.is_a?(TrueClass)
      content = "Ativo no sistema"
    elsif content.is_a?(FalseClass) || content.is_a?(NilClass)
      content = "Desativado no sistema"
    end

    content = conteudo unless conteudo.nil?

    if campo.eql?(:image) || campo.eql?(:icon)
      content = image_tag(conteudo,:alt => "Imagem campo : #{campo}")
      container << "<p><em>#{field_name}: </em><br/>#{content}</p>"
    else
      container << "<p><em>#{field_name}: </em>#{content}</p>"
    end
    container.html_safe
  end

  #metodo para exibir o search tools em telas de index
  #argumento route_for_new é a rota para onde vai ao ser clicado o botão 'novo'
  #argumento count é o total de registros encontrados
  ###opções do hash 'options'
  ### :show_new_button => true/false define se vai existir o botão para novo registro
  def search_tools(route_for_new,count,options = {})
    #options
    show_new_button = options[:show_new_button].nil? ? true : options[:show_new_button]
    #
    container = %()
    container << "<div class='box search'>"
    container << "<form action='' method=''>"
    container << "<label for='txtSearch'>Buscar por termo"
    container << "<span><input type='text' name='search' /></span></label>"
    container << "<input type='submit' class='btn' value='buscar' />"
    container << link_to('novo registro',"#{route_for_new}",:title => "novo(a) registro") if show_new_button == true
    container << "</form>"
  	container << "<span class='filters'>"
  	container << "<span><p><em>#{count}</em> registro(s) encontrado(s)</p></span>"
    container << link_to('mostrar ações','javascript:void(0)',:class => "triggerAction",:title => "clique para abri as ações")
    container << "</span>"
		container << "<span class='separator'>&nbsp;</span></div>"
		container.html_safe
  end

  #metodo para listar as dashboards na index de admin
  def list_dashboards(lista)
    container = "<div class='box dashboard'>"
      unless lista.empty?
        container << '<ul>'
        lista.each do |l|
          container << '<li>'
           container << "<a href='#{l.url}' alt='#{l.name}' title='clique para ir para o atalho : #{l.name}'>"
           container << image_tag(l.icon,:alt => l.name)
           container << "<em>#{l.name}</em>"
           container << "</a>"
          container << '</li>'
        end
        container << '</ul>'
      end
    container << '</div>'
    container.html_safe
  end

  #######################################

  # => METODOS DE LISTAGEM  - FIM

  #######################################

  #metodos que lista itens para ordenação com arrastar e soltar
  def reorder_itens(lista,modelo)
     if modelo.to_s.eql?('menu')
      id_to_list = 'order_menus_list'
     elsif modelo.to_s.eql?('sub_menu')
      id_to_list = 'order_sub_menus_list'
     end

     container = %()
     container << "<ul id='#{id_to_list}'>"
       lista.each_with_index do |l|
          container << "<li id='#{modelo.to_s.underscore.downcase}_#{l.id}'>"
          container << "<span class='handle'>[arraste]</span>&nbsp;&nbsp;&nbsp;&nbsp;"
          container << l.name
          container << "</li>"
      end
     container << "</ul>"
     container.html_safe
  end

  # ===== ===== ===== helpers de formulários - fim  ===== ===== ===== #
end

