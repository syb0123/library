#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>

#define INPUT_SIZE 255              // 책 제목을 임시저장할 문자열의 크기

typedef struct book {               // 책 구조체로 타입선언을 _book으로 함
    char* title;                    // 제목 문자열 포인터
    int checkout;                   // 대출여부 0 대출가능 1 대출
    int yearPublished;              // 출판년도
} _book;

struct node {                       // 링크드 리스트 노드
    _book* book;
    struct node* prev;              // 이전 노드 (여기선 사용하지 않음)
    struct node* next;              // 다음 노드
};

typedef struct nodeHead {           // 링크드 리스트가 연결될 구조체
    int size;                       // 리스트 크기
    struct node* head;              // 맨 앞에 위치한 노드
    struct node* tail;              // 맨 뒤에 위치한 노드
} linkedList;                       // 마찬가지로 구조체 타입선언

linkedList* createLinkedList(void);                         // 함수 프로토타입 링크드 리스트 만들기
_book* createBook(void);                                    // 새로운 책 등록
void pushNode(linkedList* list, _book* newBook);            // 생성된 노드를 꼬리 노드에 추가
void deleteLinkedList(linkedList* list);                    // 링크드 리스트 삭제하고 메모리 반환
void checkoutBook(linkedList* list);                        // 도서 대출
void returnBook(linkedList* list);                          // 도서 반납
void printList(linkedList* list);                           // 도서 출력
void menuSelect(int* menu);                                 // 메뉴 선택
char* s_gets(char* st, int size);                           // 문자열 입력에 대한 함수 (띄어쓰기도 포함 가능)

int main(void) {
    linkedList* libraryList;                                // 링크드 리스트 포인터 선언
    libraryList = createLinkedList();                       // 링크드 리스트 생성
    int menu = -1;                                          // 메뉴 옵션 디폴트 값
    printf("연결형 리스트를 이용한 도서관리 프로그램");

    while (menu != 4) {
        _book* newBook;
        switch (menu) {
        case 0:
            newBook = createBook();                     // 신규도서 생성
            pushNode(libraryList, newBook);             // 생성된 신규 도서를 링크드 리스트 꼬리 뒤로 연결
            break;
        case 1:
            checkoutBook(libraryList);
            break;
        case 2:
            returnBook(libraryList);
            break;
        case 3:
            printList(libraryList);
            break;
        default:;
                      
        }
        if (menu >= 4) {
            printf("잘못 입력하였습니다.");
        }

        menuSelect(&menu);

        if (menu == 4) {
            deleteLinkedList(libraryList);
            printf("메모리를 모두 반납하였습니다.\n");
            break;
        }
    }

    return 0;
}

linkedList* createLinkedList(void) {
    linkedList* myList = (linkedList*)calloc(1, sizeof(linkedList));         // 동적 메모리 할당으로 링크드리스트 생성
    return myList;
}

void pushNode(linkedList* list, _book* newBook) {
    struct node* newNode = (struct node*)calloc(1, sizeof(struct node));      // 동적 메모리 할당으로 노드 생성
    newNode->book = newBook;                                                    // 노드->책

    if (list->size > 0) {                                    // 리스트의 크기가 1 이상인 경우
        list->tail->next = newNode;                         // 가장 마지막에 위치한 노드 뒤에 새로운 노드 연결
        newNode->prev = list->tail;                         // 새로운 노드의 앞은 이전의 꼬리 노드
        list->tail = newNode;                               // 링크드 리스트의 꼬리노드는 새로 생성된 노드로 변경
        list->size += 1;                                    // 리스트에 연결된 숫자 증가
    }
    else {                                                  // 리스트의 크기가 1이상이 아닌경우 (즉 0일때)
        list->head = newNode;                               // 리스트가 비어있으므로 머리 노드도 새로운 노드
        list->tail = newNode;                               // 리스트가 비어있으므로 꼬리 노드도 새로운 노드
        list->size += 1;                                    // 리스트에 연결된 숫자 증가
    }
}

void deleteLinkedList(linkedList* list) {
    if (list->head) {                                        // 리스트에 머리노드가 있는 경우 (즉 리스트 사이즈가 0이 아닐때)
        struct node* temp = list->head;                     // 임시 포인터를 선언해서 해드노드를 가르키게함
        while (temp->next) {                                 // 해당 노드의 다음 노드가 있을 경우
            list->head = temp->next;                        // 링크드 리스트의 해드는 다음 노드를 가르키도록 하고
            free(temp->book->title);                        // 해당 노드에 동적 메모리 할당된 변수드를 모두 반환(free)
            free(temp->book);
            free(temp);                                     // 노드 자체도 마찬가지로 반환
            temp = list->head;                              // 임시 포인터는 다시 머리노드를 가르키게 하고 반복
        }

        free(temp->book->title);                            // 마지막 노드의 다음 노드가 NULL일때 (없을때)
        free(temp->book);                                   // 마지막으로 남은 노드의 메모리를 모두 반환
        free(temp);
        free(list);                                         // 마지막으로 링크드 리스트 자체도 반환
    }
    else {
        free(list);                                         // 리스트의 크기가 0일때 반환할 메모리가 없으므로 리스트만 반환
    }
}

void checkoutBook(linkedList* list) {
    char index[100]="";                                              // 비교문자열
    struct node* temp = NULL;                                        // 임시탐색노드

    printf("대여할 책의 제목을 입력하시오: ");
    scanf("%s\n", &index);

    if (list->size != 0)  // 도서목록이 0권이 아닐때
    {
        temp = list->head;  // 헤드부터 탐색
        while (temp != NULL) //리스트 끝까지 탐색 temp = temp -> next
        {
            if (strcmp(temp->book->title, index) == 0) // 노드 돌면서 책제목과 입력받은 제목 비교 0이면 일치
            {
                if (temp->book->checkout) // 첵제목 일치 , 대출여부가 1
                {
                    printf("%s 가 이미 대출중입니다.\n", temp->book->title);
                }
                else // 제목일치 , 대출여부 0
                {
                    temp->book->checkout = 1;
                    printf("%s 를 대출에 성공하였습니다.\n" , temp->book->title);
                }
                return; // 함수 탈출
            }
            temp = temp->next;
        }
        // 노드 탐색이 끝나도 일치하는 책이 없을경우
        printf("%s 가 존재하지 않습니다.\n", index);

    }
    else // 도서목록 0권 
    {
        printf("대여가능한 책이 없습니다.");
    }
}

void returnBook(linkedList* list) {                         // 반납의 경우도 마찬가지
    char index[100] = ""; // 비교문자열
    struct node* temp = NULL; //임시탐색노드

    printf("반납할 책의 제목을 입력하시오: ");
    scanf("%s", &index);

    if (list->size != 0)  // 도서목록이 0권이 아닐때
    {
        temp = list->head;  // 헤드부터 탐색
        while (temp != NULL) //리스트 끝까지 탐색 temp = temp -> next
        {
            if (strcmp(temp->book->title, index) == 0) // 노드 돌면서 책제목과 입력받은 제목 비교 0이면 일치
            {
                if (temp->book->checkout) // 첵제목 일치 , 대출여부가 1
                {
                    temp->book->checkout = 0;
                    printf("%s 반납에 성공하였습니다..\n", temp->book->title);
                }
                else // 제목일치 , 대출여부 0
                {
                    printf("%s 는 대출중인 책이 아닙니다.\n", temp->book->title);
                }
                return; // 함수 탈출
            }
            temp = temp->next;
        }
        // 노드 탐색이 끝나도 일치하는 책이 없을경우
        printf("찾는 책이 없습니다.\n");

    }
    else // 도서목록 0권 
    {
        printf("반납가능한 책이 없습니다.");
    }
}


void printList(linkedList* list) {
    struct node* temp = list->head;              // 출력의 경우 리스트에 노드들이 있으면 임시 포인터를 선언해서
    int index = 0;                               // 순서 출력을 위한 인덱스 변수
    if (list->size > 0) {                         // 리스트에 저장된것이 있으면
        while (temp->next) {                      // 다음 노드가 있는 경우 출력후 임시포인터를 다음노드로 해서 반복
            printf("순서 %d, 출판연도 %d, 대출여부 %d, 제목 %s\n\n", index++, temp->book->yearPublished,
                temp->book->checkout, temp->book->title);
            temp = temp->next;
        }
        printf("순서 %d, 출판연도 %d, 대출여부 %d, 제목 %s\n", index++, temp->book->yearPublished,
            temp->book->checkout, temp->book->title);        // 다음 노드가 없는경우, 마지막 노드를 출력
    }
    else {                                       // 저장된 노드가 없는경우 메세지 출력
        printf("등록된 책이 없습니다.\n");
    }
}

void menuSelect(int* menu) {
    printf("\n\n=====================\n");
    printf("0. 신규 등록\n1. 도서 대출\n2. 도서 반납\n3. 목록 출력\n4. 종료\n");
    printf("=====================\n");
    while (scanf("%d", menu) != 1) {
        printf("잘못된 입력입니다.\n");
        printf("\n\n=====================\n");
        printf("0. 신규 등록\n1. 도서 대출\n2. 도서 반납\n3. 목록 출력\n4. 종료\n");
        printf("=====================\n");
    }
}

_book* createBook(void) {
    _book* newBook = (_book*)calloc(1, sizeof(_book));        // 신규도서 동적 메모리 할당
    char* st = (char*)calloc(INPUT_SIZE, sizeof(char));       // 신규도서 제목 동적 메모리 할당

    printf("등록할 책의 제목을 입력하시오: ");
    newBook->title = s_gets(st, INPUT_SIZE);                    // s_gets함수는 띄어쓰기도 입력값으로 받음

    printf("책의 출판 연도를 입력하시오: ");
    while (scanf("%d", &newBook->yearPublished) != 1) {          // 출판년도 입력, 마찬가지로 숫자 이외의 값은 에러메세지후 반복
        printf("잘못된 입력입니다.\n책의 출판 연도를 입력하시오: ");
        while (getchar() != '\n')                                // 입력버퍼에 뉴라인을 플러시함
            continue;
    }

    printf("%s\n를 성공적으로 등록하였습니다.", newBook->title);

    return newBook;                                             // 신규도서 포인터를 반환
}

char* s_gets(char* st, int n) {
    while (getchar() != '\n')                                    // 메뉴 선택으로 남아있는 입력버퍼를 없앰
        continue;

    char* ret_val = fgets(st, n, stdin);                        // 문자열 입력 받음 최대크기 n (255)
    if (ret_val) {                                               // 문자열을 성공적으로 입력 받았다면,
        while (*st != '\n') {                                    // 뉴라인이 아닌경우
            st++;                                               // 문자열을 계속해서 검색
        }
        if (*st == '\n') {                                       // 뉴라인인경우
            *st = '\0';                                         // 널 터미네이터 (문자열 끝나는 지점을 가르키는것)로 변경
        }
        else {
            while (getchar() != '\n') {                          // 뉴라인이 나오기전에 이미 중간에 널 터미네이터가 있는 경우
                continue;                                       // 뉴라인까지 남은 입력버퍼를 플러시
            }
        }
    }

    return ret_val;                                             // 문자열 포인터값 반환
}
