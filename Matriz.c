#include <stdio.h>

#define LIMIT 3 //Limite que pode ser alterado para maiores matrizes

int main(void) {
    float Multiplicando[LIMIT][LIMIT]; //Elementos da Matriz
    float Multiplicador[LIMIT][LIMIT];
    float matrizmulti[LIMIT][LIMIT]; //Matrizes que armazena multiplicadores.

    printf("Para cada matriz, insira 9 números (linha por linha) para cada matriz:\n"); //Até próximo comentário, inserção de dados de matriz.

    printf("Matriz 1: \n");
    for (int i = 0; i < LIMIT; ++i) {
        for (int j = 0; j < LIMIT; ++j) {
            if (scanf("%f", &Multiplicando[i][j]) != 1) {
                printf("Erro na leitura.\n");
                return 1;
            }
        }
    }

    printf("Matriz 2: \n");
    for (int i = 0; i < LIMIT; ++i) {
        for (int j = 0; j < LIMIT; ++j) {
            if (scanf("%f", &Multiplicador[i][j]) != 1) {
                printf("Erro na leitura.\n");
                return 1;
            }
        }
    }

    for (int i = 0; i < LIMIT; ++i) { //Multiplicação.
        for (int j = 0; j < LIMIT; ++j) {

            matrizmulti[i][j] = 0;   // zera antes de somar

            for (int k = 0; k < LIMIT; ++k) { //Multiplica elementos de maneira linha-coluna.
                matrizmulti[i][j] += Multiplicando[i][k] * Multiplicador[k][j];
            }
        }
    }

    printf("\nResultado da multiplicação:\n"); //Demonstra matriz nova.
    for (int i = 0; i < LIMIT; ++i) {
        for (int j = 0; j < LIMIT; ++j) {
            printf("%8.3f ", matrizmulti[i][j]);
        }
        printf("\n");
    }

    return 0;
}