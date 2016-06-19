---
layout: post
title: "Promises procedurais"
date: 2016-06-19 20:23:09
description: "Aquele erro bobo que é dificil perceber"
tags:
- angular
- promise
- codereview
categories:
- angular
twitter_text: '$q.all() e promises'
---
Em um grupo que participo, surgiu uma dúvida do tipo "porquê esse código não funciona?"

Para contextualizar, basicamente foi codificado um controller, dependendo de 3+ services, onde cada um retornava um valor para ser usado posteriormente em um cálculo.

Vejamos:

{% highlight javascript %}

function calculadorController($scope, serviceA, serviceB, serviceC) {
    
    // executada assim que cria o controller
    function init() {
        obtemValorA();
        obtemValorB();
        obtemValorC();

        calcular();
    }

    // busca o valor A no service A
    function obtemValorA() {
        serviceA.obtemDados().then(function(retornoA) {
            $scope.valorA = retornoA;
        });
    }

    // busca o valor B no service B, da mesma forma que A
    // busca o valor C no service C, da mesma forma que A
    ... 

    // calcula tudo
    function calcular() {
        $scope.resultado = 
            $scope.valorA + $scope.valorB + $scope.valorC;
        ...
    }

    init();
}

{% endhighlight %}

A primeira vista, nada demais com a criação desse controller. Obtem-se os três valores, e com posse dele, realiza-se o cálculo. A pegadinha está no método _init()_! Olhe ele com carinho novamente.

Como o método _obtemValorA_ chama um serviço, que é uma _promise_, não podemos assumir que imediatamente na linha de baixo, o valor da variável _$scope.valorA_ será definida, pois há de se esperar a execução da promise antes disso. Na forma como foi implementado esse controller, a função _calcular_ será chamada antes mesmo do valor de A ser conhecido!

Esse é um dos primeiros erros bobos que passam despercebido quando se começa a escrever código assíncrono: "esperar que as execuções fluam proceduralmente". E às vezes é complicado esse entendimento para quem está começando a se aventurar.

Como precisamos de todos os resultados antes de chamarmos a função _calcular_, quais são os passos necessários para resolver isso rapidamente? Vamos lá:

1. Remover o _$scope_! - Sem relação com o problema, apenas uma [boa prática](https://github.com/johnpapa/angular-styleguide/tree/master/a1#style-y031).
2. Criar um array ou objeto com as promises necessárias.
3. Esperar a execução das promises, e só então calcular.

Para o item 3 iremos usar um serviço do angular, o [$q](https://docs.angularjs.org/api/ng/service/$q), que através do método _.all(promises)_ espera que todas sejam executadas com sucesso, e retorna uma outra promise com um array/objeto dos resultados.

Sem demora, veja como ficou:

{% highlight javascript %}

function calculadorController($q, serviceA, serviceB, serviceC) {
    var _this = this;

    var promises = {
        valorA: serviceA.obtemDados(),
        valorB: serviceB.obtemDados(),
        valorC: serviceC.obtemDados()
    };

    $q.all(promises).then(calcular);

    // calcula tudo
    function calcular(valores) {
        _this.resultado = 
            valores.valorA + valores.valorB + valores.valorC;
    }
}

{% endhighlight %}

E realife:

{% codepen NrRwZP williamthiago js 390 %}

Limpo, simples de entender, e o melhor de tudo: funcionando!



